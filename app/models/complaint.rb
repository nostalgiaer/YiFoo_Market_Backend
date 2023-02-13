class Complaint < ApplicationRecord
  belongs_to :user, class_name: 'User', foreign_key: :user_id
  belongs_to :post, class_name: 'Post', foreign_key: :post_id

  validates :user_id, presence: true
  validates :post_id, presence: true
  validates :content, presence: true, length: { minimum: 1, maximum: 65536 }

  module ComplaintStatus
    extend ApplicationRecord::ApplicationConstants

    UNSOLVED = 1
    CANCELED = 2
  end

  validates :status, presence: true, inclusion: { in: ComplaintStatus.constant_values }

  def is_solved?
    self.status == ComplaintStatus::CANCELED
  end

  def is_unsolved?
    self.status == ComplaintStatus::UNSOLVED
  end

end
