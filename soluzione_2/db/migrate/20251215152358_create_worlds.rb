class CreateWorlds < ActiveRecord::Migration[8.1]
  def change
    create_table :worlds, id: :uuid do |t|
      t.binary :matrix
      t.integer :number_generation

      t.timestamps
    end
  end
end
