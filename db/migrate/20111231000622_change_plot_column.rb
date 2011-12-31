class ChangePlotColumn < ActiveRecord::Migration
  def up
      change_table :plots do |t|
        t.change :name, :text
      end
  end

  def down
  end
end
