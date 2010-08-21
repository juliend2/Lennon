class CreateComment < ActiveRecord::Migration
  def self.up
    create_table :comments do |t|
      t.integer :post_id
      t.string :website
      t.string :email
      t.text :comment
      t.boolean :is_approved

      t.timestamps
    end
    
  end

  def self.down
    drop_table :comments
  end
end