class CreateMetawords < ActiveRecord::Migration
  def change
    create_table :metawords do |t|
      t.string :content
      t.string :youtubeid

      t.timestamps
    end
  end
end
