class ChangeColumnsInWords < ActiveRecord::Migration
  def up
    remove_column :words, :name
    add_column :words, :rating, :float    
  end

  def down
  end
end
