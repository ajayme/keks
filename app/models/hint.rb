# encoding: utf-8

class Hint < ActiveRecord::Base
  attr_accessible :sort_hint, :text

  belongs_to :question, touch: true, inverse_of: :hints

  validates :text, presence: true
  validates :question_id, presence: true
  validates :sort_hint, numericality: true, allow_blank: true

  after_save { self.question.index! }
  after_destroy { self.question.index! }

  before_save do
    Rails.cache.write("hints_last_update", Time.now)

    up = text_changed?
    self.question.update_attribute('content_changed_at', Time.now) if up
  end

  def dot
    %(#{dot_id} [label="#{dot_text}", shape=none];)
  end

  def dot_text
    'H: ' + text.gsub(/["\\]/, '')[0..15]
  end

  include DotTools
end
