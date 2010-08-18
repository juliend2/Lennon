class Tag < ActiveRecord::Base
  validates_presence_of :name
  validates_presence_of :slug
  
  has_and_belongs_to_many :posts
  
  before_validation :sluggize
  
  def sluggize
    self.slug = self.name.to_slug
  end
end