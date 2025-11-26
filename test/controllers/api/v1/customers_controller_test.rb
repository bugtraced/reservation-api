require "test_helper"

class Api::V1::CustomersControllerTest < ActionDispatch::IntegrationTest
  def setup
    @customer = Customer.create!(
      name: "John Doe",
      email: "john@example.com",
      phone: "123-456-7890"
    )
    @valid_attributes = {
      name: "Jane Doe",
      email: "jane@example.com",
      phone: "987-654-3210"
    }
    @invalid_attributes = {
      name: "",
      email: "invalid-email",
      phone: ""
    }
  end

  test "should get index" do
    get api_v1_customers_url, as: :json
    assert_response :success
    json_response = JSON.parse(response.body)
    assert_kind_of Array, json_response
  end

  test "should create customer" do
    assert_difference("Customer.count") do
      post api_v1_customers_url, params: { customer: @valid_attributes }, as: :json
    end
    assert_response :created
    json_response = JSON.parse(response.body)
    assert_equal @valid_attributes[:name], json_response["name"]
    assert_equal @valid_attributes[:email], json_response["email"]
  end

  test "should not create customer with invalid attributes" do
    assert_no_difference("Customer.count") do
      post api_v1_customers_url, params: { customer: @invalid_attributes }, as: :json
    end
    assert_response :unprocessable_entity
    json_response = JSON.parse(response.body)
    assert json_response["errors"].present?
  end

  test "should show customer" do
    get api_v1_customer_url(@customer), as: :json
    assert_response :success
    json_response = JSON.parse(response.body)
    assert_equal @customer.name, json_response["name"]
    assert_equal @customer.email, json_response["email"]
  end

  test "should return 404 for non-existent customer" do
    get api_v1_customer_url(id: 99999), as: :json
    assert_response :not_found
    json_response = JSON.parse(response.body)
    assert_equal "Customer not found", json_response["error"]
  end

  test "should update customer" do
    patch api_v1_customer_url(@customer), params: { customer: { name: "Updated Name" } }, as: :json
    assert_response :success
    @customer.reload
    assert_equal "Updated Name", @customer.name
  end

  test "should not update customer with invalid attributes" do
    original_name = @customer.name
    patch api_v1_customer_url(@customer), params: { customer: { email: "invalid-email" } }, as: :json
    assert_response :unprocessable_entity
    @customer.reload
    assert_equal original_name, @customer.name
  end

  test "should destroy customer" do
    assert_difference("Customer.count", -1) do
      delete api_v1_customer_url(@customer), as: :json
    end
    assert_response :no_content
  end
end
