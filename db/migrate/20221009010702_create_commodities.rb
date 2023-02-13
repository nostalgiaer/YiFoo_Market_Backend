class CreateCommodities < ActiveRecord::Migration[7.0]
  def change
    create_table :commodities do |t|
      t.string :name, null: false
      t.integer :price
      t.text :description, null: true, limit: 16777216

      t.timestamps
    end
  end
end
