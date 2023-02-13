class CreateComments < ActiveRecord::Migration[7.0]
  def change
    create_table :comments do |t|
      t.references :post, foreign_key: true
      t.references :user, foreign_key: true

      t.text :content, null: false, limit: 16777216

      t.timestamps
    end
  end
end
