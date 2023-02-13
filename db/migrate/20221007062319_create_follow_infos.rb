class CreateFollowInfos < ActiveRecord::Migration[7.0]
  def change
    create_table :follow_infos do |t|
      t.belongs_to :user
      t.belongs_to :post

      t.text :annotation, null: false, limit: 16777216

      t.timestamps
    end
  end
end
