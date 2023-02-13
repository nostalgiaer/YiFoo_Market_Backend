class AddLikesAndHatesToComment < ActiveRecord::Migration[7.0]
  def change
    add_column :comments, :likes, :integer, default: 0
    add_column :comments, :hates, :integer, default: 0
  end
end
