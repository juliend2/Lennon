class Post
  include MongoMapper::Document  
  key :title, String
  key :slug, String
  key :content, String
  key :published_at, Time
  timestamps!
  
  # def set_permalink
  #   self.slug = title.gsub(/\s+/, "-")
  # end
end
