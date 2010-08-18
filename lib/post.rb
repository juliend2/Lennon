=begin
class Post
  include MongoMapper::Document  
  key :title, String
  key :slug, String
  key :content, String
  key :published_at
  timestamps!
end
=end

class Post < ActiveRecord::Base
  validates_presence_of :title
  validates_presence_of :slug
  validates_presence_of :content
end