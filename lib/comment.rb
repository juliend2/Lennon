class Comment < ActiveRecord::Base
  validates_presence_of :name
  validates_presence_of :email
  validates_presence_of :comment
  validates_presence_of :post_id
  
  belongs_to :post
  
end