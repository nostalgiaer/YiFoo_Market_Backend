class Comment < ApplicationRecord
  belongs_to :reviewer, class_name: 'User', foreign_key: :user_id
  belongs_to :post, foreign_key: :post_id
  has_many :inner_comments, dependent: :destroy

  validates :user_id, presence: true
  validates :post_id, presence: true
  validates :content, presence: true, length: { minimum: 1, maximum: 65536 }

  before_validation do
    self.content ||= ""
    self.content.strip!
  end

end
