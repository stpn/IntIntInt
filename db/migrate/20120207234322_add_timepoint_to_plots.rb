class AddTimepointToPlots < ActiveRecord::Migration
  def change
    add_column :plots, :timepoint, :string
  end
end
