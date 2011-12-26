class ChangeVideoColumns < ActiveRecord::Migration
  def up
    change_column :videos, :keywords, :text
        change_column :videos, :comments, :text
  end

  def down
  end
end
