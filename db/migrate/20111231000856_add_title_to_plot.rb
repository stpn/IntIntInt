class AddTitleToPlot < ActiveRecord::Migration
  def change
    
    add_column :plots, :title, :string
    
  end
end
