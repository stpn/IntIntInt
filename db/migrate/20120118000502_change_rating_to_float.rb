class ChangeRatingToFloat < ActiveRecord::Migration
  def up
    remove_column :phrases, :rating
    add_column :phrases, :rating, :float
  end

  def down
  end
end
