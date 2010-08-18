LENNON_ROOT = ENV["LENNON_ROOT"] ||= File.dirname('..') unless defined?(LENNON_ROOT)

module Sinatra
  
  module Lennon # John Lennon was the best songwriter ever.
    
    module Helpers
      
      def text_field(name, arg_value=nil)
        if params.include? name
          value = params[name]
        else
          unless arg_value.nil?
            value = arg_value
          else
            value = ''
          end
        end
        "<input type='text' name='#{name}' value='#{value}' id='#{name}_field'/>"
      end
      
      def text_area(name, arg_value=nil)
        if params.include? name
          value = params[name]
        else
          unless arg_value.nil?
            value = arg_value
          else
            value = ''
          end
        end
        "<textarea name='#{name}' rows='8' id='#{name}_field' cols='40'>#{value}</textarea>"
      end
      
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
      app.set :conf, YAML.load_file("#{app.root('.')}/config/config.yml")[app.environment.to_s]
      app.set :dbconf, YAML.load_file("#{app.root('.')}/config/database.yml")
      
      ActiveRecord::Base.establish_connection app.dbconf[app.environment.to_s]
      
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
      
      # CRUD
      # 
      
      # Create
      app.get '/admin/posts/add/?' do
        authorize!
        erb :"admin/admin_posts_add", :layout=>:"admin/layout_admin"
      end
      
      app.post '/admin/posts/add' do
        authorize!
        post = Post.new( :title => params[:title], :slug => params[:slug], :content=>params[:content], :published_at=>Time.now )
        unless post.save
          post.errors
          @messages = post.errors.full_messages
          erb :"admin/admin_posts_add", :layout=>:"admin/layout_admin"
        else
          redirect '/admin/posts'
        end
      end
      
      # Read
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
      
      # Update
      app.get '/admin/posts/:id/edit' do 
        authorize!
        @post = Post.find(params[:id])
        erb :"admin/admin_posts_edit", :layout=>:"admin/layout_admin"
      end
      
      app.put '/admin/posts/:id' do
        authorize!
        post = Post.update( params[:id] , {
          :title=>params[:title],
          :slug=>params[:slug],
          :content=>params[:content]
        })
        unless post.save
          post.errors
          @post = Post.find(params[:id])
          @messages = post.errors.full_messages
          erb :"admin/admin_posts_edit", :layout=>:"admin/layout_admin"
        else
          redirect '/admin/posts'
        end
      end
      
      # Delete
      app.delete '/admin/posts/:id' do
        authorize!
        @post = Post.find(params[:id])
        @post.destroy
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
