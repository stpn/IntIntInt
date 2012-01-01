class ChangePhraseTimecodes < ActiveRecord::Migration
  def up
      change_column :phrases, :timecode, :text, :default => []
  end

  def down
  end
end
