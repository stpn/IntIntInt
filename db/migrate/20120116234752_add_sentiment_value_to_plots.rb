class AddSentimentValueToPlots < ActiveRecord::Migration
  def change
    add_column :plots, :sentiment_value, :float
  end
end
