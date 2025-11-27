class Api::V1::ReservationsController < ApplicationController
  before_action :set_reservation, only: [:show, :update, :destroy]

  def index
    reservations = Reservation.includes(:customer, :vehicle).all
    reservations = reservations.where(customer_id: params[:customer_id]) if params[:customer_id].present?
    reservations = reservations.where(vehicle_id: params[:vehicle_id]) if params[:vehicle_id].present?
    reservations = reservations.upcoming if params[:upcoming] == "true"
    render json: reservations, include: [ :customer, :vehicle ]
  end

  def show
    render json: @reservation, include: [ :customer, :vehicle ]
  end

  def create
    unless customer_exists?
      render_error("Customer not found", :not_found)
      return
    end
    unless vehicle_exists?
      render_error("Vehicle not found", :not_found)
      return
    end

    reservation = Reservation.new(reservation_params)
    if reservation.save
      render json: reservation, status: :created, location: api_v1_reservation_path(reservation)
    else
      render_validation_errors(reservation)
    end
  end

  def update
    if @reservation.update(reservation_params)
      render json: @reservation
    else
      render_validation_errors(@reservation)
    end
  end

  def destroy
    if @reservation.destroy
      head :no_content
    else
      render_validation_errors(@reservation)
    end
  end

  private

  def set_reservation
    @reservation = Reservation.find_by(id: params[:id])
    render_not_found("Reservation") unless @reservation
  end

  def reservation_params
    params.require(:reservation).permit(:customer_id, :vehicle_id, :start_time, :end_time, :status)
  end

  def customer_exists?
    return true unless reservation_params[:customer_id].present?
    Customer.exists?(reservation_params[:customer_id])
  end

  def vehicle_exists?
    return true unless reservation_params[:vehicle_id].present?
    Vehicle.exists?(reservation_params[:vehicle_id])
  end
end
