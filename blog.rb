%w{
  rubygems
  sinatra
  mongo_mapper
  lib/lennon
}.each { |r| require r }

set :sessions, true

class Post
  include MongoMapper::Document  
  key :title, String
  key :content, String
  key :published_at, Time
  timestamps!
end

['/', '/page/:page'].each do |path|
  get path do 
    @per_page = options.per_page
    @count = Post.count
    @posts = Post.paginate(:per_page => options.per_page, :page => params[:page] || 1)
    erb :posts
  end
end

get '/test' do
  options.conf['blog_title']
end
