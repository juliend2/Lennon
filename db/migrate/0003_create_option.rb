class CreateOption < ActiveRecord::Migration
  def self.up
    create_table :options do |t|
      t.string :option_name
      t.string :option_value

      t.timestamps
    end
    
  end

  def self.down
    drop_table :options
  end
end