class Stat < ActiveRecord::Base
  default_scope where("stats.created_at > ?", 30.days.ago)

  attr_protected :answer_id, :question_id, :user_id, :correct

  belongs_to :question
  belongs_to :user
  belongs_to :answer

  def anonymous?
    user_id == -1
  end

  def skipped?
    answer_id == -1
  end

  def correct?
    correct && !skipped?
  end

  def wrong?
    !correct && !skipped?
  end
end
