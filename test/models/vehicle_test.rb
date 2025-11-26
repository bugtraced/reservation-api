require "test_helper"

class VehicleTest < ActiveSupport::TestCase
  def setup
    @customer = Customer.create!(
      name: "John Doe",
      email: "john@example.com",
      phone: "123-456-7890"
    )
    @vehicle = Vehicle.new(
      make: "Toyota",
      model: "Camry",
      year: 2020,
      color: "Blue",
      license_plate: "ABC123",
      customer: @customer
    )
  end

  test "should be valid with valid attributes" do
    assert @vehicle.valid?
  end

  test "should require make" do
    @vehicle.make = nil
    assert_not @vehicle.valid?
    assert_includes @vehicle.errors[:make], "can't be blank"
  end

  test "should require model" do
    @vehicle.model = nil
    assert_not @vehicle.valid?
    assert_includes @vehicle.errors[:model], "can't be blank"
  end

  test "should require year" do
    @vehicle.year = nil
    assert_not @vehicle.valid?
    assert_includes @vehicle.errors[:year], "can't be blank"
  end

  test "should require year to be greater than 1900" do
    @vehicle.year = 1899
    assert_not @vehicle.valid?
  end

  test "should accept year up to next year" do
    @vehicle.year = Date.current.year + 1
    assert @vehicle.valid?
  end

  test "should require color" do
    @vehicle.color = nil
    assert_not @vehicle.valid?
    assert_includes @vehicle.errors[:color], "can't be blank"
  end

  test "should require license_plate" do
    @vehicle.license_plate = nil
    assert_not @vehicle.valid?
    assert_includes @vehicle.errors[:license_plate], "can't be blank"
  end

  test "should require unique license_plate" do
    @vehicle.save!
    duplicate = Vehicle.new(
      make: "Honda",
      model: "Civic",
      year: 2021,
      color: "Red",
      license_plate: @vehicle.license_plate,
      customer: @customer
    )
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:license_plate], "has already been taken"
  end

  test "should belong to customer" do
    assert_equal @customer, @vehicle.customer
  end

  test "should have many reservations" do
    @vehicle.save!
    reservation = Reservation.create!(
      customer: @customer,
      vehicle: @vehicle,
      start_time: 1.day.from_now,
      end_time: 1.day.from_now + 2.hours,
      status: "pending"
    )
    assert_includes @vehicle.reservations, reservation
  end
end
