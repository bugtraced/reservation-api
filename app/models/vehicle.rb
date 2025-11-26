class Vehicle < ApplicationRecord
  belongs_to :customer
  has_many :reservations, dependent: :destroy

  validates :make, presence: true, length: { minimum: 1, maximum: 50 }
  validates :model, presence: true, length: { minimum: 1, maximum: 50 }
  validates :year, presence: true, numericality: { only_integer: true, greater_than: 1900, less_than_or_equal_to: -> { Date.current.year + 1 } }
  validates :color, presence: true, length: { minimum: 1, maximum: 30 }
  validates :license_plate, presence: true, length: { minimum: 1, maximum: 20 }, uniqueness: true
end
