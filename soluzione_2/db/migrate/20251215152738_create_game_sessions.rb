class CreateGameSessions < ActiveRecord::Migration[8.1]
  def change
    create_table :game_sessions do |t|
      t.string :status
      t.references :user, type: :uuid, null: false, foreign_key: true
      t.references :world, type: :uuid, null: false, foreign_key: true

      t.timestamps
    end
  end
end
