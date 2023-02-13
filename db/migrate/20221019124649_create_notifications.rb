class CreateNotifications < ActiveRecord::Migration[7.0]
  def change
    create_table :notifications do |t|
      t.integer :status, null: false
      t.integer :direction, null: false

      t.timestamps
    end
  end
end
