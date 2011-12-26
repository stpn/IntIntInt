class CreateDiscards < ActiveRecord::Migration
  def change
    create_table :discards do |t|
      t.string :youtubeid

      t.timestamps
    end
  end
end
