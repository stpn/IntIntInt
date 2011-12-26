class DropRatingFromVideo < ActiveRecord::Migration
  def up
    remove_column :videos, :rating
    
  end

  def down
  end
end
