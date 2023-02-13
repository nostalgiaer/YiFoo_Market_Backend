class AddHeatToPost < ActiveRecord::Migration[7.0]
  def change
    add_column :posts, :heat, :bigint
  end
end
