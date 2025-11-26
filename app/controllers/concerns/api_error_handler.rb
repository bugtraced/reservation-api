module ApiErrorHandler
  extend ActiveSupport::Concern

  included do
    rescue_from ActionController::ParameterMissing, with: :handle_parameter_missing
    rescue_from ActiveRecord::RecordInvalid, with: :handle_record_invalid
    rescue_from ActiveRecord::RecordNotDestroyed, with: :handle_record_not_destroyed
  end

  private

  def render_error(message, status = :unprocessable_entity)
    render json: { error: message }, status: status
  end

  def render_validation_errors(record)
    render json: { errors: record.errors.full_messages }, status: :unprocessable_entity
  end

  def render_not_found(resource_name)
    render json: { error: "#{resource_name} not found" }, status: :not_found
  end

  def handle_parameter_missing(exception)
    render json: { error: "Missing required parameter: #{exception.param}" }, status: :bad_request
  end

  def handle_record_invalid(exception)
    render_validation_errors(exception.record)
  end

  def handle_record_not_destroyed(exception)
    render json: { error: "Unable to delete record: #{exception.record.errors.full_messages.join(', ')}" }, status: :unprocessable_entity
  end
end

