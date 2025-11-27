class Api::V1::CustomersController < ApplicationController
  before_action :set_customer, only: [ :show, :update, :destroy ]

  def index
    customers = Customer.includes(:vehicles, :reservations).all
    render json: customers, include: [ :vehicles, :reservations ]
  end

  def show
    render json: @customer, include: [ :vehicles, :reservations ]
  end

  def create
    customer = Customer.new(customer_params)
    if customer.save
      render json: customer, status: :created, location: api_v1_customer_path(customer)
    else
      render_validation_errors(customer)
    end
  end

  def update
    if @customer.update(customer_params)
      render json: @customer
    else
      render_validation_errors(@customer)
    end
  end

  def destroy
    if @customer.destroy
      head :no_content
    else
      render_validation_errors(@customer)
    end
  end

  private

  def set_customer
    @customer = Customer.find_by(id: params[:id])
    render_not_found("Customer") unless @customer
  end

  def customer_params
    params.require(:customer).permit(:name, :email, :phone)
  end
end
