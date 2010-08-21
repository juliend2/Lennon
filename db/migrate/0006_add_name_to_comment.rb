class AddNameToComment < ActiveRecord::Migration
  def self.up
    add_column :comments, :name, :string
  end

  def self.down
    remove_column :comments, :name
  end
end

