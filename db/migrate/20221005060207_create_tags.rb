class CreateTags < ActiveRecord::Migration[7.0]
  def change
    create_table :tags do |t|
      t.string :tag_name, null: false
      t.integer :reference_number

      t.timestamps
    end

    create_table :posts_tags do |t|
      t.belongs_to :tag
      t.belongs_to :post
    end
  end
end
