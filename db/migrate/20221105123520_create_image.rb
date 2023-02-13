class CreateImage < ActiveRecord::Migration[7.0]
  def change
    create_table :images do |t|
      t.integer :category, null: false

      t.references :user, foreign_key: true
      t.references :commodity, foreign_key: true

      t.timestamps
    end
  end
end
