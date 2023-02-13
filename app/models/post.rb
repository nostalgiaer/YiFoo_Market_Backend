class Post < ApplicationRecord
  belongs_to :author, class_name: 'User', foreign_key: :user_id
  has_many :comments, dependent: :destroy
  has_many :inner_comments, through: :comments
  has_many :follow_infos, dependent: :destroy
  has_many :commodity_groups, dependent: :destroy
  has_many :complaints, dependent: :destroy
  has_many :commodities, class_name: 'Commodity', through: :commodity_groups, source: :commodity
  has_many :notifications, class_name: 'Notification', through: :indents
  has_many :indents, class_name: 'Indent', through: :commodities
  has_many :replies, class_name: 'Reply', dependent: :destroy
  has_and_belongs_to_many :tags, class_name: 'Tag'

  validates :user_id, presence: true
  validates :title, presence: true, length: { minimum: 1, maximum: 128 }
  validates :content, presence: true, length: { minimum: 0, maximum: 65536 }

  module PostCategory
    extend ApplicationRecord::ApplicationConstants

    BUY = 1
    SELL = 2
  end

  validates :category, presence: true, inclusion: { in: PostCategory.constant_values }

  before_validation do
    self.content ||= ''
    self.content.strip!
  end

  def is_buy_post?
    self.category == PostCategory::BUY
  end

  def is_sell_post?
    self.category == PostCategory::SELL
  end

end
