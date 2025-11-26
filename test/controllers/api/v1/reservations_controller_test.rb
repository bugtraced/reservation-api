require "test_helper"

class Api::V1::ReservationsControllerTest < ActionDispatch::IntegrationTest
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
    @reservation = Reservation.create!(
      customer: @customer,
      vehicle: @vehicle,
      start_time: 1.day.from_now,
      end_time: 1.day.from_now + 2.hours,
      status: "pending"
    )
    @valid_attributes = {
      customer_id: @customer.id,
      vehicle_id: @vehicle.id,
      start_time: 2.days.from_now,
      end_time: 2.days.from_now + 2.hours,
      status: "pending"
    }
    @invalid_attributes = {
      customer_id: @customer.id,
      vehicle_id: @vehicle.id,
      start_time: 1.day.ago,
      end_time: 2.days.ago,
      status: "pending"
    }
  end

  test "should get index" do
    get api_v1_reservations_url, as: :json
    assert_response :success
    json_response = JSON.parse(response.body)
    assert_kind_of Array, json_response
  end

  test "should filter reservations by customer_id" do
    other_customer = Customer.create!(
      name: "Jane Doe",
      email: "jane@example.com",
      phone: "987-654-3210"
    )
    other_vehicle = Vehicle.create!(
      make: "Honda",
      model: "Civic",
      year: 2021,
      color: "Red",
      license_plate: "XYZ789",
      customer: other_customer
    )
    other_reservation = Reservation.create!(
      customer: other_customer,
      vehicle: other_vehicle,
      start_time: 1.day.from_now,
      end_time: 1.day.from_now + 2.hours,
      status: "pending"
    )
    get api_v1_reservations_url(customer_id: @customer.id), as: :json
    assert_response :success
    json_response = JSON.parse(response.body)
    assert json_response.any? { |r| r["id"] == @reservation.id }
    assert_not json_response.any? { |r| r["id"] == other_reservation.id }
  end

  test "should filter reservations by vehicle_id" do
    other_vehicle = Vehicle.create!(
      make: "Honda",
      model: "Civic",
      year: 2021,
      color: "Red",
      license_plate: "XYZ789",
      customer: @customer
    )
    other_reservation = Reservation.create!(
      customer: @customer,
      vehicle: other_vehicle,
      start_time: 1.day.from_now,
      end_time: 1.day.from_now + 2.hours,
      status: "pending"
    )
    get api_v1_reservations_url(vehicle_id: @vehicle.id), as: :json
    assert_response :success
    json_response = JSON.parse(response.body)
    assert json_response.any? { |r| r["id"] == @reservation.id }
    assert_not json_response.any? { |r| r["id"] == other_reservation.id }
  end

  test "should filter upcoming reservations" do
    past_reservation = Reservation.create!(
      customer: @customer,
      vehicle: @vehicle,
      start_time: 2.days.ago,
      end_time: 2.days.ago + 2.hours,
      status: "completed"
    )
    get api_v1_reservations_url(upcoming: "true"), as: :json
    assert_response :success
    json_response = JSON.parse(response.body)
    assert json_response.any? { |r| r["id"] == @reservation.id }
    assert_not json_response.any? { |r| r["id"] == past_reservation.id }
  end

  test "should create reservation" do
    assert_difference("Reservation.count") do
      post api_v1_reservations_url, params: { reservation: @valid_attributes }, as: :json
    end
    assert_response :created
    json_response = JSON.parse(response.body)
    assert_equal @valid_attributes[:status], json_response["status"]
  end

  test "should not create reservation with invalid attributes" do
    assert_no_difference("Reservation.count") do
      post api_v1_reservations_url, params: { reservation: @invalid_attributes }, as: :json
    end
    assert_response :unprocessable_entity
    json_response = JSON.parse(response.body)
    assert json_response["errors"].present?
  end

  test "should not create overlapping reservations" do
    overlapping_attributes = {
      customer_id: @customer.id,
      vehicle_id: @vehicle.id,
      start_time: @reservation.start_time + 1.hour,
      end_time: @reservation.end_time + 1.hour,
      status: "pending"
    }
    assert_no_difference("Reservation.count") do
      post api_v1_reservations_url, params: { reservation: overlapping_attributes }, as: :json
    end
    assert_response :unprocessable_entity
  end

  test "should show reservation" do
    get api_v1_reservation_url(@reservation), as: :json
    assert_response :success
    json_response = JSON.parse(response.body)
    assert_equal @reservation.status, json_response["status"]
  end

  test "should return 404 for non-existent reservation" do
    get api_v1_reservation_url(id: 99999), as: :json
    assert_response :not_found
    json_response = JSON.parse(response.body)
    assert_equal "Reservation not found", json_response["error"]
  end

  test "should update reservation" do
    patch api_v1_reservation_url(@reservation), params: { reservation: { status: "confirmed" } }, as: :json
    assert_response :success
    @reservation.reload
    assert_equal "confirmed", @reservation.status
  end

  test "should not update reservation with invalid attributes" do
    original_status = @reservation.status
    patch api_v1_reservation_url(@reservation), params: { reservation: { status: "invalid" } }, as: :json
    assert_response :unprocessable_entity
    @reservation.reload
    assert_equal original_status, @reservation.status
  end

  test "should destroy reservation" do
    assert_difference("Reservation.count", -1) do
      delete api_v1_reservation_url(@reservation), as: :json
    end
    assert_response :no_content
  end
end
