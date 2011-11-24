class AddCommentsToVideo < ActiveRecord::Migration
  def change
    add_column :videos, :comments, :string
  end
  
  def drop
  remove_columd :videos, :comments
  end
    
end
