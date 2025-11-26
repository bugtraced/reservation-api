class Customer < ApplicationRecord
  has_many :vehicles, dependent: :destroy
  has_many :reservations, dependent: :destroy

  validates :name, presence: true, length: { minimum: 2, maximum: 100 }
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }, uniqueness: true
  validates :phone, presence: true, format: { with: /\A[\d\s\-\(\)]+\z/, message: "must be a valid phone number" }
end
