require "test_helper"

class Api::V1::VehiclesControllerTest < ActionDispatch::IntegrationTest
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
    @valid_attributes = {
      make: "Honda",
      model: "Civic",
      year: 2021,
      color: "Red",
      license_plate: "XYZ789",
      customer_id: @customer.id
    }
    @invalid_attributes = {
      make: "",
      model: "",
      year: nil,
      color: "",
      license_plate: "",
      customer_id: @customer.id
    }
  end

  test "should get index" do
    get api_v1_vehicles_url, as: :json
    assert_response :success
    json_response = JSON.parse(response.body)
    assert_kind_of Array, json_response
  end

  test "should filter vehicles by customer_id" do
    other_customer = Customer.create!(
      name: "Jane Doe",
      email: "jane@example.com",
      phone: "987-654-3210"
    )
    other_vehicle = Vehicle.create!(
      make: "Ford",
      model: "Focus",
      year: 2019,
      color: "Black",
      license_plate: "DEF456",
      customer: other_customer
    )
    get api_v1_vehicles_url(customer_id: @customer.id), as: :json
    assert_response :success
    json_response = JSON.parse(response.body)
    assert json_response.any? { |v| v["id"] == @vehicle.id }
    assert_not json_response.any? { |v| v["id"] == other_vehicle.id }
  end

  test "should create vehicle" do
    assert_difference("Vehicle.count") do
      post api_v1_vehicles_url, params: { vehicle: @valid_attributes }, as: :json
    end
    assert_response :created
    json_response = JSON.parse(response.body)
    assert_equal @valid_attributes[:make], json_response["make"]
    assert_equal @valid_attributes[:model], json_response["model"]
  end

  test "should not create vehicle with invalid attributes" do
    assert_no_difference("Vehicle.count") do
      post api_v1_vehicles_url, params: { vehicle: @invalid_attributes }, as: :json
    end
    assert_response :unprocessable_entity
    json_response = JSON.parse(response.body)
    assert json_response["errors"].present?
  end

  test "should show vehicle" do
    get api_v1_vehicle_url(@vehicle), as: :json
    assert_response :success
    json_response = JSON.parse(response.body)
    assert_equal @vehicle.make, json_response["make"]
    assert_equal @vehicle.model, json_response["model"]
  end

  test "should return 404 for non-existent vehicle" do
    get api_v1_vehicle_url(id: 99999), as: :json
    assert_response :not_found
    json_response = JSON.parse(response.body)
    assert_equal "Vehicle not found", json_response["error"]
  end

  test "should update vehicle" do
    patch api_v1_vehicle_url(@vehicle), params: { vehicle: { color: "Green" } }, as: :json
    assert_response :success
    @vehicle.reload
    assert_equal "Green", @vehicle.color
  end

  test "should not update vehicle with invalid attributes" do
    original_color = @vehicle.color
    patch api_v1_vehicle_url(@vehicle), params: { vehicle: { year: 1800 } }, as: :json
    assert_response :unprocessable_entity
    @vehicle.reload
    assert_equal original_color, @vehicle.color
  end

  test "should destroy vehicle" do
    assert_difference("Vehicle.count", -1) do
      delete api_v1_vehicle_url(@vehicle), as: :json
    end
    assert_response :no_content
  end
end
