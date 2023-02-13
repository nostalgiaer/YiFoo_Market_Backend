class InnerComment < ApplicationRecord
  belongs_to :comment, class_name:  'Comment', foreign_key: :comment_id
  belongs_to :reviewer, class_name: 'User', foreign_key: :user_id

  validates :user_id, presence: true
  validates :comment_id, presence: true
  validates :content, presence: true, length: { minimum: 1, maximum: 65536 }

  module CommentObject
    extend ApplicationRecord::ApplicationConstants

    OUTER_COMMENT = 1
    INNER_COMMENT = 2
  end

  validates :reply_object_type, presence: true, inclusion: { in: CommentObject.constant_values }

  before_validation do
    self.content ||= ""
    self.content.strip!
  end

  def reply_outer_comment?
    self.reply_object_type == CommentObject::OUTER_COMMENT
  end

  def reply_inner_comment?
    self.reply_object_type == CommentObject::INNER_COMMENT
  end

end
