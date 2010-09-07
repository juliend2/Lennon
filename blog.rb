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
  @latest_comments = Comment.all(:limit=>7, :order=>'created_at DESC', :conditions=>"post_id IS NOT NULL")
  @months = Post.get_months
  
end

begin
  conf = Conf.new
rescue ConfigurationNotFoundError => e
end

# for / and for and /page/1, /page/2, etc
["#{conf.blog_url_prefix}/?", "#{conf.blog_url_prefix}/page/:page"].each do |path|
  get path do 
    @count = Post.count
    offset = ((params[:page]||0).to_i-1)*options.conf.posts_per_page
    @posts = Post.all(:limit=>options.conf.posts_per_page, 
                      :offset=> offset,
                      :order=>'published_at DESC')
    @paginator = Paginator.new((@count / options.conf.posts_per_page.to_f).ceil, params[:page])
    erb "themes/#{conf.theme_name}/posts".to_sym, :layout=>"themes/#{conf.theme_name}/layout".to_sym
  end
end

# Display a single post
# for /:year/:month/:day/:slug
get %r{#{conf.blog_url_prefix}/(\d{4})\/(\d{1,2})\/(\d{1,2})\/([A-Za-z0-9\.\-]+)\/?} do |year, month, day, slug|
  time = Time.gm(year,month,day).midnight
  @post = Post.all(:conditions=>{
      :published_at=>time.to_time..(time + 1.day).to_time, 
      :slug=>slug
    })
  if @post.length > 0
    @post = @post[0]
    erb "themes/#{conf.theme_name}/single".to_sym, :layout=>"themes/#{conf.theme_name}/layout".to_sym
  else
    status 404
    "Not found"
  end
end

post "#{conf.blog_url_prefix}/post-comment" do
  if post = Post.find(params[:post_id])
    comment = post.comments.new(
      :name=>params[:name], 
      :email=>params[:email], 
      :website=>params[:website],
      :comment=>params[:comment],
      :is_approved=>options.conf.auto_approve_comments,
      :user_agent=>env['HTTP_USER_AGENT'],
      :ip_address=>env['REMOTE_ADDR']
      )
    if comment.save
      redirect "#{conf.blog_url_prefix}/#{post.created_at.year}/#{post.created_at.month}/#{post.created_at.day}/#{post.slug}"
    else
      @messages = comment.errors.full_messages
      erb "themes/#{conf.theme_name}/post_comment".to_sym, :layout=>"themes/#{conf.theme_name}/layout_error".to_sym
    end
  else
    'Could not find this post. Please try again.'
  end
end

# Tag actions
# /tags/my-tag and /tags/my-tag/page/2
["#{conf.blog_url_prefix}/tags/:tag_slug/?", 
"#{conf.blog_url_prefix}/tags/:tag_slug/page/:page/?"].each do |path|
  get path do
    @tag = Tag.find_by_slug(params[:tag_slug])
    @count = @tag.posts.count
    offset = ((params[:page]||0).to_i-1)*options.conf.posts_per_page
    @posts = @tag.posts.all(:limit=>options.conf.posts_per_page, 
                      :offset=> offset,
                      :order=>'created_at DESC')
    @paginator = Paginator.new((@count / options.conf.posts_per_page.to_f).ceil, params[:page], "/tags/#{@tag.slug}")
    erb "themes/#{conf.theme_name}/tags".to_sym, :layout=>"themes/#{conf.theme_name}/layout".to_sym
  end
end

# Archive actions
# /tags/my-tag and /tags/my-tag/page/2
["#{conf.blog_url_prefix}/archive/:year/:month/?", 
"#{conf.blog_url_prefix}/archive/:year/:month/page/:page/?"].each do |path|
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
    erb "themes/#{conf.theme_name}/archives".to_sym, :layout=>"themes/#{conf.theme_name}/layout".to_sym
  end
end

# RSS feed
get "#{conf.blog_url_prefix}/rss.xml" do
  @posts = Post.all(:limit=>20)
  builder "themes/#{conf.theme_name}/rss".to_sym
end