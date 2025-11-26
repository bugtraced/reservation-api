require "test_helper"

class ReservationTest < ActiveSupport::TestCase
  def setup
    @customer = Customer.create!(
      name: "John Doe",
      email: "john@example.com",
      phone: "123-456-7890"
    )
    @vehicle = Vehicle.create!(
      make: "Toyota",
      model: "Camry",
      year: 2020,
      color: "Blue",
      license_plate: "ABC123",
      customer: @customer
    )
    @reservation = Reservation.new(
      customer: @customer,
      vehicle: @vehicle,
      start_time: 1.day.from_now,
      end_time: 1.day.from_now + 2.hours,
      status: "pending"
    )
  end

  test "should be valid with valid attributes" do
    assert @reservation.valid?
  end

  test "should require start_time" do
    @reservation.start_time = nil
    assert_not @reservation.valid?
    assert_includes @reservation.errors[:start_time], "can't be blank"
  end

  test "should require end_time" do
    @reservation.end_time = nil
    assert_not @reservation.valid?
    assert_includes @reservation.errors[:end_time], "can't be blank"
  end

  test "should require end_time to be after start_time" do
    @reservation.end_time = @reservation.start_time - 1.hour
    assert_not @reservation.valid?
    assert_includes @reservation.errors[:end_time], "must be after start time"
  end

  test "should require start_time to be in the future" do
    @reservation.start_time = 1.day.ago
    assert_not @reservation.valid?
    assert_includes @reservation.errors[:start_time], "must be in the future"
  end

  test "should require status" do
    @reservation.status = nil
    assert_not @reservation.valid?
    assert_includes @reservation.errors[:status], "can't be blank"
  end

  test "should accept valid status values" do
    valid_statuses = %w[pending confirmed cancelled completed]
    valid_statuses.each do |status|
      @reservation.status = status
      assert @reservation.valid?, "#{status} should be valid"
    end
  end

  test "should reject invalid status values" do
    @reservation.status = "invalid"
    assert_not @reservation.valid?
  end

  test "should not allow overlapping reservations for same vehicle" do
    @reservation.save!
    overlapping = Reservation.new(
      customer: @customer,
      vehicle: @vehicle,
      start_time: @reservation.start_time + 1.hour,
      end_time: @reservation.end_time + 1.hour,
      status: "pending"
    )
    assert_not overlapping.valid?
    assert_includes overlapping.errors[:base], "Time slot overlaps with an existing reservation"
  end

  test "should allow reservations for different vehicles at same time" do
    @reservation.save!
    other_vehicle = Vehicle.create!(
      make: "Honda",
      model: "Civic",
      year: 2021,
      color: "Red",
      license_plate: "XYZ789",
      customer: @customer
    )
    same_time = Reservation.new(
      customer: @customer,
      vehicle: other_vehicle,
      start_time: @reservation.start_time,
      end_time: @reservation.end_time,
      status: "pending"
    )
    assert same_time.valid?
  end

  test "should allow cancelled reservations to overlap" do
    @reservation.status = "cancelled"
    @reservation.save!
    overlapping = Reservation.new(
      customer: @customer,
      vehicle: @vehicle,
      start_time: @reservation.start_time + 1.hour,
      end_time: @reservation.end_time + 1.hour,
      status: "pending"
    )
    assert overlapping.valid?
  end

  test "upcoming scope should return future reservations" do
    @reservation.save!
    past_reservation = Reservation.create!(
      customer: @customer,
      vehicle: @vehicle,
      start_time: 2.days.ago,
      end_time: 2.days.ago + 2.hours,
      status: "completed"
    )
    upcoming = Reservation.upcoming
    assert_includes upcoming, @reservation
    assert_not_includes upcoming, past_reservation
  end

  test "should belong to customer" do
    assert_equal @customer, @reservation.customer
  end

  test "should belong to vehicle" do
    assert_equal @vehicle, @reservation.vehicle
  end
end
