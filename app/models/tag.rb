class Tag < ApplicationRecord
  has_and_belongs_to_many :posts, class_name: 'Post'

  validates :tag_name, allow_nil: false, presence: true,
            length: { minimum: 0, maximum: 65536 }, uniqueness: { case_sensitive: false }

end
