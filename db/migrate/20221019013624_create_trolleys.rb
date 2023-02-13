class CreateTrolleys < ActiveRecord::Migration[7.0]
  def change
    create_table :trolleys do |t|
      t.integer :number, null: false

      t.references :user, foreign_key: true
      t.references :commodity, foreign_key: true

      t.timestamps
    end
  end
end
