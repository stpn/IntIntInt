class AddViewsKeywordsToVideos < ActiveRecord::Migration
  def change
    add_column :videos, :keywords, :string
    add_column :videos, :views, :string
  end
end
