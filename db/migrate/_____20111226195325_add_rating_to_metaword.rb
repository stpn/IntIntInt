class AddRatingToMetaword < ActiveRecord::Migration
  def change
    add_column :metawords, :rating, :string
  end
end
