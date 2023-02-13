class Notification < ApplicationRecord
  belongs_to :sender, class_name: 'User', foreign_key: :user_id
  belongs_to :deliver, class_name: 'User', foreign_key: :deliver_id
  belongs_to :indent, class_name: 'Indent', foreign_key: :indent_id

  validates :user_id, presence: true
  validates :deliver_id, presence: true
  validates :indent_id, presence: true
  validates :content, presence: true, length: { minimum: 1, maximum: 1000 }

  module NotificationDirection
    extend ApplicationRecord::ApplicationConstants

    TO_SELLER = 1
    TO_BUYER = 2
  end

  validates :direction, presence: true, inclusion: { in: NotificationDirection.constant_values }

  module NotificationStatus
    extend ApplicationRecord::ApplicationConstants

    CHECKED = 1
    UNCHECKED = 2
    CONFIRMED = 3
  end

  validates :status, presence: true, inclusion: { in: NotificationStatus.constant_values }

  before_validation do
    self.content ||= " "
    self.status = 2 if self.status.nil?
  end

  def checked?
    self.status == NotificationStatus::CHECKED
  end

  def unchecked?
    self.status == NotificationStatus::UNCHECKED
  end

  def to_seller?
    self.direction == NotificationDirection::TO_SELLER
  end

  def to_buyer?
    self.direction == NotificationDirection::TO_BUYER
  end

end
