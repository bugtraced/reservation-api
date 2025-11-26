class CreateVehicles < ActiveRecord::Migration[8.1]
  def change
    create_table :vehicles do |t|
      t.string :make, null: false
      t.string :model, null: false
      t.integer :year, null: false
      t.string :color, null: false
      t.string :license_plate, null: false
      t.references :customer, null: false, foreign_key: true

      t.timestamps
    end

    add_index :vehicles, :license_plate, unique: true
  end
end
