class RenameQueryToPlot < ActiveRecord::Migration
  def change
          rename_table :queries, :plots
  end
      
end
