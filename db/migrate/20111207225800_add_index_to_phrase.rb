class AddIndexToPhrase < ActiveRecord::Migration
  def change
    
      add_index :phrases, :video_id
  end
end
