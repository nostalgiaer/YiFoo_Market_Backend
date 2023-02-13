class CreateInnerComments < ActiveRecord::Migration[7.0]
  def change
    create_table :inner_comments do |t|
      t.references :user, foreign_key: true
      t.references :comment, foreign_key: true

      t.text :content, null: false, limit: 16777216
      t.integer :reply_object_type, null: false
      t.bigint :reply_comment_id, null: true

      t.timestamps
    end
  end
end
