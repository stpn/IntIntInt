class AddGalaxyToPlots < ActiveRecord::Migration
  def change
    add_column :plots, :galaxy, :string
  end
end
