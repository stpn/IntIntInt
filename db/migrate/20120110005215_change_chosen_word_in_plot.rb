class ChangeChosenWordInPlot < ActiveRecord::Migration
  def up
    
    change_column :plots, :chosen_word, :text, :default => []
    
  end

  def down
  end
end
