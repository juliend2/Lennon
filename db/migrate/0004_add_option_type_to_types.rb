class AddOptionTypeToTypes < ActiveRecord::Migration
  def self.up
    add_column :options, :option_type, :string
  end

  def self.down
    remove_column :options, :option_type
  end
end

