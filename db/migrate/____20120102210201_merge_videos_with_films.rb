class MergeVideosWithFilms < ActiveRecord::Migration
   def self.up
      execute "INSERT videos SELECT * FROM films;"
      
      drop_table :films
    end

    def self.down
      raise IrreversibleMigration
    end
  end