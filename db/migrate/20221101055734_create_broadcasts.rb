class CreateBroadcasts < ActiveRecord::Migration[7.0]
  def change
    create_table :broadcasts do |t|
      t.text :content, null: false
      t.string :title, null: false

      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
