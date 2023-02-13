class CommodityGroup < ApplicationRecord
  belongs_to :post, foreign_key: :post_id
  has_one :commodity, class_name:  'Commodity', dependent: :destroy

  validates :number, presence: true, numericality: { only_integer: true,
                                                     :greater_than_or_equal_to => 0 }
  validates :post_id, presence: true
end
