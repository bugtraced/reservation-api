class CreateReservations < ActiveRecord::Migration[8.1]
  def change
    create_table :reservations do |t|
      t.references :customer, null: false, foreign_key: true
      t.references :vehicle, null: false, foreign_key: true
      t.datetime :start_time, null: false
      t.datetime :end_time, null: false
      t.string :status, null: false, default: "pending"

      t.timestamps
    end

    add_index :reservations, [ :vehicle_id, :start_time, :end_time ]
    add_index :reservations, :status
  end
end
