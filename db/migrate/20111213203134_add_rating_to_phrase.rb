class AddRatingToPhrase < ActiveRecord::Migration
  def change
    add_column :phrases, :rating, :boolean
  end
end
