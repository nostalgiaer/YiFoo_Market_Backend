class Indent < ApplicationRecord
  belongs_to :commodity, class_name: 'Commodity', foreign_key: :commodity_id
  belongs_to :user, class_name: 'User', foreign_key: :user_id
  has_many :notifications, dependent: :destroy

  validates :num, presence: true
  validates :commodity_id, presence: true

  module IndentStatus
    extend ApplicationRecord::ApplicationConstants

    PROCEEDING = 1
    FINISH = 2
  end

  validates :status, presence: true, inclusion: { in: IndentStatus.constant_values }

  def finished?
    self.status == IndentStatus::FINISH
  end

  def proceeding?
    self.status == IndentStatus::PROCEEDING
  end

end
