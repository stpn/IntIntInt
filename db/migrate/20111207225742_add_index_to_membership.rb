class AddIndexToMembership < ActiveRecord::Migration
  def change
    
    
      add_index :memberships, :video_id
      add_index :memberships, :metaword_id
    
    
  end
end
