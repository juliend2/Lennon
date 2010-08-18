class Post < ActiveRecord::Base
  validates_presence_of :title
  validates_presence_of :slug
  validates_presence_of :content
  
  has_and_belongs_to_many :tags 
  
  before_validation :sluggize
  
  def sluggize
    self.slug = self.title.to_slug
  end
end