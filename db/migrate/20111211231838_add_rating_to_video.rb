class AddRatingToVideo < ActiveRecord::Migration
  def change
    add_column :videos, :rating, :string
  end
end
