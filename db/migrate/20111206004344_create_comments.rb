class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.string :content
      t.integer :video_id
      t.string :youtubeid

      t.timestamps
    end
  end
end
