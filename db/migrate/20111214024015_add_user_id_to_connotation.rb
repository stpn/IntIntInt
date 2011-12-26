class AddUserIdToConnotation < ActiveRecord::Migration
  def change
    add_column :connotations, :user_id, :integer
  end
end
