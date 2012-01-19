class ChangeRatingToFloat < ActiveRecord::Migration
  def up
    change_column :phrases, :rating, :float    
  end

  def down
  end
end
