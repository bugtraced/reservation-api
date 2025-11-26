require "test_helper"

class CustomerTest < ActiveSupport::TestCase
  def setup
    @customer = Customer.new(
      name: "John Doe",
      email: "john@example.com",
      phone: "123-456-7890"
    )
  end

  test "should be valid with valid attributes" do
    assert @customer.valid?
  end

  test "should require name" do
    @customer.name = nil
    assert_not @customer.valid?
    assert_includes @customer.errors[:name], "can't be blank"
  end

  test "should require name to be at least 2 characters" do
    @customer.name = "A"
    assert_not @customer.valid?
  end

  test "should require email" do
    @customer.email = nil
    assert_not @customer.valid?
    assert_includes @customer.errors[:email], "can't be blank"
  end

  test "should require valid email format" do
    @customer.email = "invalid-email"
    assert_not @customer.valid?
  end

  test "should require unique email" do
    @customer.save
    duplicate = Customer.new(
      name: "Jane Doe",
      email: @customer.email,
      phone: "987-654-3210"
    )
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:email], "has already been taken"
  end

  test "should require phone" do
    @customer.phone = nil
    assert_not @customer.valid?
    assert_includes @customer.errors[:phone], "can't be blank"
  end

  test "should accept valid phone formats" do
    valid_phones = ["123-456-7890", "(123) 456-7890", "1234567890", "123 456 7890"]
    valid_phones.each do |phone|
      @customer.phone = phone
      assert @customer.valid?, "#{phone} should be valid"
    end
  end

  test "should have many vehicles" do
    @customer.save
    vehicle = Vehicle.create!(
      make: "Toyota",
      model: "Camry",
      year: 2020,
      color: "Blue",
      license_plate: "ABC123",
      customer: @customer
    )
    assert_includes @customer.vehicles, vehicle
  end

  test "should have many reservations" do
    @customer.save
    vehicle = Vehicle.create!(
      make: "Toyota",
      model: "Camry",
      year: 2020,
      color: "Blue",
      license_plate: "ABC123",
      customer: @customer
    )
    reservation = Reservation.create!(
      customer: @customer,
      vehicle: vehicle,
      start_time: 1.day.from_now,
      end_time: 1.day.from_now + 2.hours,
      status: "pending"
    )
    assert_includes @customer.reservations, reservation
  end

  test "should destroy associated vehicles when destroyed" do
    @customer.save
    vehicle = Vehicle.create!(
      make: "Toyota",
      model: "Camry",
      year: 2020,
      color: "Blue",
      license_plate: "ABC123",
      customer: @customer
    )
    @customer.destroy
    assert_not Vehicle.exists?(vehicle.id)
  end
end
