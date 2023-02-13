class AddReferenceToCommodity < ActiveRecord::Migration[7.0]
  def change
    add_reference :commodities, :commodity_group, foreign_key: true
  end
end
