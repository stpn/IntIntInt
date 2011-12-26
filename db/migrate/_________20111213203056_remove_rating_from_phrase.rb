class RemoveRatingFromPhrase < ActiveRecord::Migration
  def up
    
    remove_column :phrases, :rating
    
  end

  def down
  end
end
