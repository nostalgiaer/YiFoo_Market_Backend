class Broadcast < ApplicationRecord
  belongs_to :publisher, class_name: 'User', foreign_key: :user_id

  validates :content, presence: true, length: { minimum: 1, maximum: 65536 }
  validates :title, presence: true, length: { minimum: 1, maximum: 65536 }
  validates :user_id, presence: true

end
