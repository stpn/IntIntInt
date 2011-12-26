class ChangePhraseColumns2 < ActiveRecord::Migration
  def up
      change_table :phrases do |t|
        t.change :timecode, :text
      end
  end

  def down
  end
end
