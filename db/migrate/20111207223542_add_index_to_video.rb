class AddIndexToVideo < ActiveRecord::Migration
  def change
    
 
    add_index :videos, :content
    add_index :videos, :keywords
    add_index :videos, :comments       
  
    
    
  end
end
