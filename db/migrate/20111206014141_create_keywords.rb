class CreateKeywords < ActiveRecord::Migration
  def change
    create_table :keywords do |t|
      t.string :content
      t.integer :video_id

      t.timestamps
    end
  end
end
