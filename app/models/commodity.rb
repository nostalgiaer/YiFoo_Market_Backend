class Commodity < ApplicationRecord
  belongs_to :commodity_group, foreign_key: :commodity_group_id
  has_many :indents, dependent: :destroy, foreign_key: :commodity_id
  has_many :trolleys, dependent: :destroy
  has_many :images, dependent: :destroy

  validates :commodity_group_id, presence: true
  validates :name, presence: true, length: { minimum: 1, maximum: 65536 }
  validates :price, presence: true, numericality:
    { only_integer: true, greater_than_or_equal_to: 0 }
  validates :description, presence: false, length: { minimum: 0, maximum: 65536 }

end
