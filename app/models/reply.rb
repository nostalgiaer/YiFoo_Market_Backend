class Reply < ApplicationRecord
  belongs_to :reply_user, class_name: 'User', foreign_key: :user_id
  belongs_to :post, class_name: 'Post', foreign_key: :post_id

  validates :content, presence: true, length: { minimum: 1, maximum: 65536 }
  validates :user_id, presence: true
  validates :post_id, presence: true

  module ReplyStatus
    extend ApplicationRecord::ApplicationConstants

    CHECKED = 1
    UNCHECKED = 2
  end

  validates :status, presence: true, inclusion: { in: ReplyStatus.constant_values }

  def is_checked?
    self.status == ReplyStatus::CHECKED
  end

  def is_unchecked?
    self.status == ReplyStatus::UNCHECKED
  end

end
