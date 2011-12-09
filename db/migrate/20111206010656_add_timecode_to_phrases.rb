class AddTimecodeToPhrases < ActiveRecord::Migration
  def change
    add_column :phrases, :timecode, :string
  end
end
