class AddDownloadToVideo < ActiveRecord::Migration
  def change
    add_column :videos, :download, :boolean
  end
end
