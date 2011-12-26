class ChangePhraseColumns < ActiveRecord::Migration
  def up
    change_table :phrases do |t|
      t.change :content, :text
    end
    
    change_table :comments do |t|
      t.change :content, :text
    end
    
  end

  def down
  end
end
