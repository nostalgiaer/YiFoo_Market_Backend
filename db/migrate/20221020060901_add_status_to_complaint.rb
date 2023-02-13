class AddStatusToComplaint < ActiveRecord::Migration[7.0]
  def change
    add_column :complaints, :status, :integer
  end
end
