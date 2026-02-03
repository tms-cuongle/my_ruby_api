class CreateTokenBlacklists < ActiveRecord::Migration[8.1]
  def change
    create_table :token_blacklists do |t|
      t.string :jti
      t.datetime :exp

      t.timestamps
    end
    add_index :token_blacklists, :jti, unique: true
  end
end
