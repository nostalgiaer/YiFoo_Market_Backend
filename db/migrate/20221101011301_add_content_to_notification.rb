class AddContentToNotification < ActiveRecord::Migration[7.0]
  def change
    add_column :notifications, :content, :text
    add_reference :notifications, :indent, foreign_key: true
  end
end
