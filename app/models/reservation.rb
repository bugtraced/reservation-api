class Reservation < ApplicationRecord
  belongs_to :customer
  belongs_to :vehicle

  validates :start_time, presence: true
  validates :end_time, presence: true
  validates :status, presence: true, inclusion: { in: %w[pending confirmed cancelled completed] }
  validate :end_time_after_start_time
  validate :no_overlapping_reservations
  validate :start_time_in_future

  scope :upcoming, -> { where("start_time > ?", Time.current).where(status: %w[pending confirmed]) }
  scope :by_date_range, ->(start_date, end_date) { where("start_time >= ? AND end_time <= ?", start_date, end_date) }

  private

  def end_time_after_start_time
    return unless start_time.present? && end_time.present?

    errors.add(:end_time, "must be after start time") if end_time <= start_time
  end

  def no_overlapping_reservations
    return unless start_time.present? && end_time.present? && vehicle_id.present?

    overlapping = Reservation.where(vehicle_id: vehicle_id)
                            .where.not(id: id)
                            .where(status: %w[pending confirmed])
                            .where("(start_time < ? AND end_time > ?) OR (start_time < ? AND end_time > ?)",
                                   end_time, start_time, start_time, end_time)

    errors.add(:base, "Time slot overlaps with an existing reservation") if overlapping.exists?
  end

  def start_time_in_future
    return unless start_time.present?
    return if %w[completed cancelled].include?(status)

    errors.add(:start_time, "must be in the future") if start_time < Time.current
  end
end
