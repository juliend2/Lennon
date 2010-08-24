class Comment < ActiveRecord::Base
  validates_presence_of :name
  validates_presence_of :email
  validates_presence_of :comment
  validates_presence_of :post_id
  validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, :on => :create
  
  belongs_to :post
  
end