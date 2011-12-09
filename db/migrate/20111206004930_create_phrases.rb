class CreatePhrases < ActiveRecord::Migration
  def change
    create_table :phrases do |t|
      t.string :content
      t.integer :video_id
      t.string :youtubeid

      t.timestamps
    end
  end
end
