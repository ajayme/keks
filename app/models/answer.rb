# encoding: utf-8

class Answer < ApplicationRecord
  # attr_accessible :correct, :text

  validates :text, :uniqueness => { :scope => :question_id,
    :message => "Es gibt bereits eine Antwort mit genau dem gleichen Text zu dieser Frage." }

  belongs_to :question, inverse_of: :answers, touch: :content_changed_at, counter_cache: true
  alias_method :parent, :question

  # i.e. this answer has many questions and acts as parent to them
  has_many :questions, :as => :parent
  attr_readonly :questions_count

  has_many :stats

  has_and_belongs_to_many :categories


  after_save { self.question.index! }
  after_destroy { self.question.index! }

  before_save do
    Rails.cache.write(:answers_last_update, Time.now)

    up = text_changed? || correct_changed?
    self.question.update_attribute('content_changed_at', Time.now) if up
  end

  include TraversalTools

  def check_ratio
    return -1 if question.matrix_validate?
    all = question.stats.pluck(:selected_answers).flatten
    me = all - [id]
    return 1-me.size.to_f/all.size.to_f
  end


  def get_all_subquestions
    questions + categories.map { |c| c.questions }.flatten
  end

  def released?
    question.released?
  end


  def link_text
    "Antwort #{link_text_short}"
  end

  def link_text_short
    "#{question.ident}/A#{id}"
  end

  include DotTools

  def dot
    txt = 'A: ' + id.to_s
    %(#{dot_id} [label="#{txt}", shape=hexagon, color=#{correct? ? 'green' : 'red'}];\n)
  end
end
