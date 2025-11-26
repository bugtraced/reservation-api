class Api::V1::VehiclesController < ApplicationController
  before_action :set_vehicle, only: [:show, :update, :destroy]

  def index
    vehicles = Vehicle.includes(:customer, :reservations).all
    vehicles = vehicles.where(customer_id: params[:customer_id]) if params[:customer_id].present?
    render json: vehicles, include: [:customer, :reservations]
  end

  def show
    render json: @vehicle, include: [:customer, :reservations]
  end

  def create
    return render_error("Customer not found", :not_found) unless customer_exists?

    vehicle = Vehicle.new(vehicle_params)
    if vehicle.save
      render json: vehicle, status: :created, location: api_v1_vehicle_path(vehicle)
    else
      render_validation_errors(vehicle)
    end
  end

  def update
    if @vehicle.update(vehicle_params)
      render json: @vehicle
    else
      render_validation_errors(@vehicle)
    end
  end

  def destroy
    if @vehicle.destroy
      head :no_content
    else
      render_validation_errors(@vehicle)
    end
  end

  private

  def set_vehicle
    @vehicle = Vehicle.find_by(id: params[:id])
    return render_not_found("Vehicle") unless @vehicle
  end

  def vehicle_params
    params.require(:vehicle).permit(:make, :model, :year, :color, :license_plate, :customer_id)
  end

  def customer_exists?
    return true unless vehicle_params[:customer_id].present?
    Customer.exists?(vehicle_params[:customer_id])
  end
end
