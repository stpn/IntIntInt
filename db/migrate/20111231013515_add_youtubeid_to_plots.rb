class AddYoutubeidToPlots < ActiveRecord::Migration
  def change
    add_column :plots, :youtubeid, :text
    
  end
end
