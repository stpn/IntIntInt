class CreateConnotations < ActiveRecord::Migration
  def change
    create_table :connotations do |t|
      t.string :rating
      t.string :username
      t.integer :phrase_id

      t.timestamps
    end
  end
end
