LENNON_ROOT = ENV["LENNON_ROOT"] ||= File.dirname('..') unless defined?(LENNON_ROOT)

module Sinatra
  
  module Lennon # John Lennon was the best songwriter ever.
    
    module Helpers
      
      def link_to(label, path)
        "<a href='#{path}'>#{label}</a>"
      end
      
      def delete_btn(label, path)
        <<-HTML
        <form method="post" action="#{ path }" onsubmit="return confirm('Are you sure?');">
          <input type="hidden" name="_method" value="delete" />
          <button type="submit">#{ label }</button>
        </form>
        HTML
      end
      
      # pagination-related helpers
      # 
      def paginate(max_pages, current)
        links = []
        current = current || '1'
        1.upto max_pages do |i|
          if i.to_s == current
            links << i
          else
            links << link_to( i, "/page/#{i}")
          end
        end
        links.join(', ')
      end
      
      # Auth-related helpers
      # 
      def authorized?
        session[:authorized]
      end

      def authorize!
        redirect '/admin/login' unless authorized?
      end

      def logout!
        session[:authorized] = false
      end
      
    end
    
    def self.registered(app)
      app.helpers Lennon::Helpers
      app.set :per_page, 4
      app.set :sessions, true
      app.set :conf, YAML.load_file("#{app.root('.')}/config.yml")[app.environment.to_s]
      
      MongoMapper.connection = Mongo::Connection.new(app.conf['mongo_host'], app.conf['mongo_port'], :auto_reconnect => true)
      MongoMapper.database = app.conf['mongo_db']
      MongoMapper.database.authenticate(app.conf['mongo_user'], app.conf['mongo_pass'])
      
      # Admin
      # 
      app.get '/admin/?' do
        if authorized?
          "<a href='/admin/posts'>Manage Posts</a>"
        else
          redirect '/admin/login'
        end
      end
      
      app.get '/admin/login/?' do
        erb :"admin/admin_login", :layout=>:"admin/layout_admin"
      end
      
      app.post '/admin/login' do
        if params[:username] == app.conf['admin_user'] && params[:password] == app.conf['admin_pass']
          session[:authorized] = true
          redirect '/'
        else
          session[:authorized] = false
          redirect '/admin/login'
        end
      end
      
      app.get '/admin/logout/?' do
        logout!
        redirect '/'
      end
      
      app.get '/admin/posts/?' do
        authorize!
        @posts = Post.all.reverse
        erb :"admin/admin_posts", :layout=>:"admin/layout_admin"
      end
      
      app.get '/admin/posts/:id' do
        authorize!
        @post = Post.find(params[:id])
        erb :"admin/admin_post", :layout=>:"admin/layout_admin"
      end
      
      app.delete '/admin/posts/:id' do
        authorize!
        @post = Post.find(params[:id])
        @post.destroy
        redirect '/admin/posts'
      end
      
      app.get '/admin/posts/add/?' do
        authorize!
        erb :"admin/admin_posts_add", :layout=>:"admin/layout_admin"
      end
      
      app.post '/admin/posts/add' do
        authorize!
        Post.create( :title => params[:title], :slug => params[:slug], :content=>params[:content], :published_at=>Time.now ).save
        redirect '/admin/posts'
      end
      
      # 404 error
      app.not_found do
        '<h1>I only found this 404 error :(</h1>'
      end
      
    end
    
  end
  
  register Lennon
end
