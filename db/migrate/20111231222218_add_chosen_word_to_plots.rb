class AddChosenWordToPlots < ActiveRecord::Migration
  def change
    add_column :plots, :chosen_word, :string
  end
end
