class Trolley < ApplicationRecord
  belongs_to :user, class_name: 'User', foreign_key: :user_id
  belongs_to :commodity, class_name: 'Commodity', foreign_key: :commodity_id

  validates :user_id, presence: true
  validates :commodity_id, presence: true
  validates :number, presence: true, numericality: { only_integer: true,
                                                     :greater_than_or_equal_to => 0 }
end
