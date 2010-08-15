class Post
  include MongoMapper::Document  
  key :title, String
  key :slug, String
  key :content, String
  key :published_at
  timestamps!
  
  validates_presence_of :title
  validates_presence_of :slug
  validates_presence_of :content
  # def set_permalink
  #   self.slug = title.gsub(/\s+/, "-")
  # end
end
