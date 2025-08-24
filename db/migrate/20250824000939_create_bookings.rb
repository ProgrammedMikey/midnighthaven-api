class CreateBookings < ActiveRecord::Migration[8.0]
  def change
    create_table :bookings do |t|
      t.references :listing, null: false, foreign_key: true
      t.references :guest, null: false, foreign_key: { to_table: :users }
      t.date :start_date
      t.date :end_date
      t.string :status

      t.timestamps
    end
  end
end
