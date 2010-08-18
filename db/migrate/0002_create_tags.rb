class CreateTags < ActiveRecord::Migration
  def self.up
    create_table :tags do |t|
      t.string :name
      t.string :slug

      t.timestamps
    end
    
    create_table :posts_tags, :id => false do |t|
      t.references :post, :tag
    end
  end

  def self.down
    drop_table :tags
    drop_table :posts_tags
  end
end

