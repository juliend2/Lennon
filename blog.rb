%w{
  rubygems
  sinatra
  active_record
  lib/conf
  lib/lennon
  lib/option
  lib/post
  lib/comment
  lib/tag
  lib/paginator
  lib/string
}.each { |r| require r }

# for every pages :
before do
  content_type "text/html", :charset => "utf-8"
  @tags = Tag.all
  @months = Post.get_months
end

# for / and for and /page/1, /page/2, etc
['/', '/page/:page'].each do |path|
  get path do 
    @count = Post.count
    offset = ((params[:page]||0).to_i-1)*options.conf.posts_per_page
    @posts = Post.all(:limit=>options.conf.posts_per_page, 
                      :offset=> offset,
                      :order=>'published_at DESC')
    @paginator = Paginator.new((@count / options.conf.posts_per_page.to_f).ceil, params[:page])
    erb :posts
  end
end

# Display a single post
# for /:year/:month/:day/:slug
get %r{/(\d{4})\/(\d{1,2})\/(\d{1,2})\/([A-Za-z0-9\.\-]+)\/?} do |year, month, day, slug|
  time = Time.gm(year,month,day).midnight
  @post = Post.all(:include=>[:comments],
    :conditions=>{
      :published_at=>time.to_time..(time + 1.day).to_time, 
      :slug=>slug,
      'comments.is_approved'=>true
    })
  if @post.length > 0
    @post = @post[0]
    erb :post
  else
    status 404
    "Not found"
  end
end

post '/post-comment' do
  if post = Post.find(params[:post_id])
    comment = post.comments.new(:name=>params[:name], :email=>params[:email], :website=>params[:website],:comment=>params[:comment],:is_approved=>options.conf.auto_approve_comments)
    if comment.save
      redirect "/#{post.created_at.year}/#{post.created_at.month}/#{post.created_at.day}/#{post.slug}"
    else
      @messages = comment.errors.full_messages
      erb :post_comment
    end
  else
    'Could not find this post. Please try again.'
  end
end

# Tag actions
# /tags/my-tag and /tags/my-tag/page/2
['/tags/:tag_slug/?', '/tags/:tag_slug/page/:page/?'].each do |path|
  get path do
    @tag = Tag.find_by_slug(params[:tag_slug])
    @count = @tag.posts.count
    offset = ((params[:page]||0).to_i-1)*options.conf.posts_per_page
    @posts = @tag.posts.all(:limit=>options.conf.posts_per_page, 
                      :offset=> offset,
                      :order=>'created_at DESC')
    @paginator = Paginator.new((@count / options.conf.posts_per_page.to_f).ceil, params[:page], "/tags/#{@tag.slug}")
    erb :tags
  end
end

# Archive actions
# /tags/my-tag and /tags/my-tag/page/2
['/archive/:year/:month/?', '/archive/:year/:month/page/:page/?'].each do |path|
  get path do
    beginning = Time.gm(params[:year],params[:month]).beginning_of_month
    ending = Time.gm(params[:year],params[:month]).end_of_month
    @count = Post.count(:conditions=>{ :published_at=>beginning..ending })
    offset = ((params[:page]||0).to_i-1)*options.conf.posts_per_page
    @posts = Post.all(:limit=>options.conf.posts_per_page, 
                      :offset=> offset,
                      :order=>'published_at DESC',
                      :conditions=>{ :published_at=>beginning..ending })
    @paginator = Paginator.new((@count / options.conf.posts_per_page.to_f).ceil, params[:page], "/archive/#{params[:year]}/#{params[:month]}")
    erb :archives
  end
end

# RSS feed
get '/rss.xml' do
  @posts = Post.all(:limit=>20)
  builder :rss
end