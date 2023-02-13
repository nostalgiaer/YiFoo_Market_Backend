class CreateIndents < ActiveRecord::Migration[7.0]
  def change
    create_table :indents do |t|
      t.integer :num, null: false
      t.integer :status, null: false

      t.references :commodity, foreign_key: true

      t.timestamps
    end
  end
end
