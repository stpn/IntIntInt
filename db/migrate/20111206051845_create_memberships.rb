class CreateMemberships < ActiveRecord::Migration
  def change
    create_table :memberships do |t|
      t.integer :metaword_id
      t.integer :video_id

      t.timestamps
    end
  end
end
