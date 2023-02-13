class AddReferenceToReply < ActiveRecord::Migration[7.0]
  def change
    add_column :replies, :deliver_id, :bigint
  end
end
