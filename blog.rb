%w{
  rubygems
  sinatra
  mongo_mapper
  lib/lennon
  lib/post
  lib/paginator
}.each { |r| require r }

['/', '/page/:page'].each do |path|
  get path do 
    @per_page = options.per_page
    @count = Post.count
    @posts = Post.paginate(:per_page => options.per_page, :page => params[:page] || 1, :order=>'published_at DESC')
    @paginator = Paginator.new((@count / @per_page.to_f).ceil, params[:page])
    erb :posts
  end
end

get '/:year/:month/:day/:slug' do
  time = Time.gm(params[:year],params[:month],params[:day]).midnight
  @post = Post.all(:published_at=>{
    '$gt' => time.to_time,
    '$lt' => (time + 1.day).to_time
  }, :slug=>params[:slug])
  if @post.length > 0
    @post = @post[0]
    erb :post
  else
    status 404
    "Not found"
  end
end
