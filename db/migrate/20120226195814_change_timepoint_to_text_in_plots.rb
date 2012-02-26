class ChangeTimepointToTextInPlots < ActiveRecord::Migration
  def up
    change_column :plots, :timepoint, :text, :default => []
    
  end

  def down
  end
end
