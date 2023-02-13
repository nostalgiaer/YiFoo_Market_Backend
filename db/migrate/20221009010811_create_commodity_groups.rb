class CreateCommodityGroups < ActiveRecord::Migration[7.0]
  def change
    create_table :commodity_groups do |t|
      t.references :post, foreign_key: true

      t.integer :number, null: false
      t.timestamps
    end
  end
end
