class AddIpUaToComment < ActiveRecord::Migration
  def self.up
    add_column :comments, :ip_address, :string
    add_column :comments, :user_agent, :string
  end

  def self.down
    remove_column :comments, :ip_address
    remove_column :comments, :user_agent
  end
end
