class User < ApplicationRecord
  has_one_attached :photo
  include AttachedImageHandler

  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, presence: true, uniqueness: true
end
