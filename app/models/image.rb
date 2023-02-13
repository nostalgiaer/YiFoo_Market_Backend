class Image < ApplicationRecord
  belongs_to :user, class_name: 'User'
  belongs_to :commodity, class_name: 'Commodity'

  validates :user_id, presence: true, allow_blank: true
  validates :commodity_id, presence: true, allow_nil: true, allow_blank: true

  module ImageCategory
    extend ApplicationRecord::ApplicationConstants

    COMMODITY_IMAGE = 1
    USER_APPEARANCE = 2
  end

  validates :category, presence: true, inclusion: { in: ImageCategory.constant_values }
end
