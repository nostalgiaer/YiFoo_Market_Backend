class FollowInfo < ApplicationRecord
  belongs_to :follower, class_name: 'User', foreign_key: :user_id
  belongs_to :post, foreign_key: :post_id

  validates :annotation, presence: true, length: { minimum: 1, maximum: 65536 }
  validates :user_id, presence: true
  validates :post_id, presence: true

end
