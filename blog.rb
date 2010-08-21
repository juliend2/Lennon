%w{
  rubygems
  sinatra
  active_record
  lib/conf
  lib/lennon
  lib/option
  lib/post
  lib/tag
  lib/paginator
  lib/string
}.each { |r| require r }

['/', '/page/:page'].each do |path|
  get path do 
    @count = Post.count
    offset = ((params[:page]||0).to_i-1)*options.per_page
    @posts = Post.all(:limit=>options.per_page, 
                      :offset=> offset,
                      :order=>'published_at DESC')
    @paginator = Paginator.new((@count / options.per_page.to_f).ceil, params[:page])
    erb :posts
  end
end

# get '/:year/:month/:day/:slug' do
get %r{/(\d{4})\/(\d{1,2})\/(\d{1,2})\/([A-Za-z0-9\.\-]+)\/?} do |year, month, day, slug|
  time = Time.gm(year,month,day).midnight
  @post = Post.all(:conditions=>{
      :published_at=>time.to_time..(time + 1.day).to_time, 
      :slug=>slug
    })
  if @post.length > 0
    @post = @post[0]
    erb :post
  else
    status 404
    "Not found"
  end
end

['/tags/:tag_slug/?', '/tags/:tag_slug/page/:page/?'].each do |path|
  get path do
    @tag = Tag.find_by_slug(params[:tag_slug])
    @count = @tag.posts.count
    offset = ((params[:page]||0).to_i-1)*options.per_page
    @posts = @tag.posts.all(:limit=>options.per_page, 
                      :offset=> offset,
                      :order=>'created_at DESC')
    @paginator = Paginator.new((@count / options.per_page.to_f).ceil, params[:page], "/tags/#{@tag.slug}")
    erb :tags
  end
end

get '/rss.xml' do
  @posts = Post.all(:limit=>20)
  builder :rss
end