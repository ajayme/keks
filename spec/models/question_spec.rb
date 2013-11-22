# encoding: utf-8

require 'spec_helper'

describe Question do
  let(:question) { FactoryGirl.build(:question) }
  let(:question_matrix) { FactoryGirl.create(:question_matrix) }
  let(:user) { FactoryGirl.create(:user) }
  let(:user_with_stats) { FactoryGirl.create(:user_with_stats) }

  before :each do
    Rails.cache.clear
  end

  it "can be saved" do
    expect(question).to be_valid
  end

  it "is valid with all answers false" do
    q = question
    q.parent = FactoryGirl.build(:category)
    q.answers << FactoryGirl.build(:answer_wrong)
    expect(q.incomplete_reason).to eql("")
    expect(q.complete?).to eql(true)
  end

  it "retrieves subquestions" do
    q1 = FactoryGirl.create(:question_with_answers)
    q2 = FactoryGirl.create(:question_parent_answer)
    q3 = FactoryGirl.create(:question_parent_answer)
    q2.parent = q1.answers.first
    q2.save
    expect(q1.subquestions).to include(q2)
    expect(q1.subquestions).not_to include(q1, q3)
  end

  it "retrieves subcategories" do
    c1 = FactoryGirl.create(:category_with_questions)
    c2 = FactoryGirl.create(:category_with_questions)
    c3 = FactoryGirl.create(:category_with_questions)

    q = c1.questions.first
    a = q.answers.first
    c2.answers << a
    c2.save

    expect(q.subcategories).to include(c2)
    expect(q.subcategories).not_to include(c1, c3)
  end

  it "gives sane correct ratio numbers" do
    expect(question.correct_ratio_user(user)).to eql(0)

    u = user_with_stats
    q = u.stats.first.question
    s = q.stats.where(user_id: u.id).pluck(:correct)
    ratio = s.count(true) / s.size.to_f
    expect(q.correct_ratio_user(u)).to eql(ratio)
  end

  it "can’t be saved without text" do
    expect(FactoryGirl.build(:question, :text => "")).not_to be_valid
  end

  it "is complete with answers" do
    q = FactoryGirl.create(:question_parent_category)
    # not using be_empty here so that the test directly shows the reason
    # why a question is not considered complete
    q.incomplete_reason.should eq ""
    q.complete?.should be_true
  end

  it "is incomplete without answers" do
    q = FactoryGirl.create(:question_no_answers)
    q.complete?.should be_false
    q.incomplete_reason.should_not eq ""
  end

  it "detects matrix validation" do
    q = question_matrix
    expect(q.matrix_validate?).to be_true
    expect(q.matrix_solution).to eql("3  3  18")
  end

  it "builds dot with parent category" do
    q = FactoryGirl.create(:question_parent_category_subs)
    10.times { q.parent.questions << FactoryGirl.build(:question_subs) }
    q.parent.answers << FactoryGirl.build(:answer)
    dot = q.dot_region
    expect(dot).to include(q.ident, q.parent.ident, q.answers.first.id.to_s)
  end

  it "builds dot with parent answer" do
    q = FactoryGirl.create(:question_parent_answer_subs)
    q.parent.categories << FactoryGirl.create(:category_with_questions)
    q.parent.save

    subq = FactoryGirl.create(:question_parent_answer)
    subq.parent = q.parent.question.answers.first
    subq.save

    dot = q.dot_region
    expect(dot).to include(q.ident, q.parent.id.to_s, q.answers.first.id.to_s)
  end

  it "detects unreachable questions" do
    q = FactoryGirl.create(:question_parent_answer_subs)
    q.subquestions.each do |qq|
      qq.parent.question.study_path = 123
      qq.parent.question.save

      expect(qq.complete?).to be_true

      qq.study_path = 99
      qq.save
      Rails.cache.clear

      expect(qq.complete?).to be_false
      expect(qq.incomplete_reason).to include("andere Zielgruppe")
    end
  end

  describe "#dot_region_siblings" do
    it "limits amount of visible siblings" do
      c = FactoryGirl.create(:category_with_questions)
      siblings_dot = c.questions.sample.send(:dot_region_siblings, true)
      expect(siblings_dot).to include("_hidden_siblings")
    end
  end

  describe "#get_root_categories" do
    it "returns empty array for questions without parent" do
      q = FactoryGirl.build(:question, parent: nil)
      expect(q.get_root_categories).to eql([])
    end
  end

  describe "#get_parent_category" do
    it "returns nil for questions without parent" do
      q = FactoryGirl.build(:question, parent: nil)
      expect(q.get_parent_category).to be_nil
    end

    it "returns direct parent if parent is a category" do
      expect(question.get_parent_category).to eql(question.parent)
    end

    it "returns direct parent if parent is a category" do
      expect(question.get_parent_category).to eql(question.parent)
    end
  end
end
