%w{
  rubygems
  sinatra
  mongo_mapper
  lib/lennon
  lib/post
}.each { |r| require r }

['/', '/page/:page'].each do |path|
  get path do 
    @per_page = options.per_page
    @count = Post.count
    @posts = Post.paginate(:per_page => options.per_page, :page => params[:page] || 1)
    erb :posts
  end
end
