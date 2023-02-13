class User < ApplicationRecord
  has_many :posts, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :follow_infos, dependent: :destroy
  has_many :follows, through: :follow_infos, source: :post
  has_many :trolleys, dependent: :destroy
  has_many :complaints, dependent: :destroy
  has_many :notifications, dependent: :destroy
  has_many :broadcasts, dependent: :destroy
  has_many :indents, dependent: :destroy
  has_many :replies, dependent: :destroy
  has_many :images, dependent: :destroy

  validates :username, presence: true, length: { minimum: 1, maximum: 50 }
  validates :email, presence: true, length: { minimum: 1, maximum: 255 },
            format: { with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i },
            uniqueness: { case_sensitive: false }, allow_nil: false
  validates :student_id, allow_nil: false, uniqueness: { case_sensitive: true }
  validates :password, presence: true, length: { minimum: 6 }, on: :create

  module UserRole
    extend ApplicationRecord::ApplicationConstants

    STUDENT = 1
    ADMIN = 2
    SYSTEM_ROOT = 3
  end

  validates :user_role, presence: true, inclusion: { in: UserRole.constant_values }

  module UserUpload
    extend ApplicationRecord::ApplicationConstants

    DEFAULT = 0
    UPLOADED = 1
  end

  validates :uploaded, presence: true, inclusion: { in: UserUpload.constant_values }

  before_save do
    self.email = email.downcase
  end

  before_validation do
    self.user_role ||= UserRole::STUDENT
  end

  def upload_image?
    self.uploaded == UserUpload::UPLOADED
  end

  def is_student?
    self.user_role == UserRole::STUDENT
  end

  def is_admin?
    self.user_role == UserRole::ADMIN
  end

  def authenticated? (password)
    self.password == password
  end

  def authenticate_email? (email)
    self.email == email
  end
end
