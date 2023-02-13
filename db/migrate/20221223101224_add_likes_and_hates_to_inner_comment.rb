class AddLikesAndHatesToInnerComment < ActiveRecord::Migration[7.0]
  def change
    add_column :inner_comments, :likes, :integer, default: 0
    add_column :inner_comments, :hates, :integer, default: 0
  end
end
