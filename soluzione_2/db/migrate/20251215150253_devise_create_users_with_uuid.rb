class DeviseCreateUsersWithUuid < ActiveRecord::Migration[8.1]
  def change
    create_table :users, id: :uuid, default: 'uuid_generate_v4()' do |t|
      ## Database authenticatable
      t.string :email,              null: false, default: ""
      t.string :encrypted_password, null: false, default: ""

      ## Recoverable
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at

      t.timestamps null: false
    end

    add_index :users, :email,                unique: true
    add_index :users, :reset_password_token, unique: true

  end
end
