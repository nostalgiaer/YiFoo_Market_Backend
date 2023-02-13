class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.string :username
      t.string :email
      t.string :password
      t.string :student_id

      t.integer :failures_on_login
      t.datetime :last_failure_on_login

      t.timestamps
    end
  end
end
