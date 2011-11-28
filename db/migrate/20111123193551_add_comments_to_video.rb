class AddCommentsToVideo < ActiveRecord::Migration
  def change
    add_column :videos, :comments, :text
  end
  
  def drop
  remove_column :videos, :comments
  end
    
end
