class AddReferenceToNotification < ActiveRecord::Migration[7.0]
  def change
    add_reference :notifications, :user, foreign_key: true
    add_column :notifications, :deliver_id, :bigint
  end
end
