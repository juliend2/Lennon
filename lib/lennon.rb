LENNON_ROOT = ENV["LENNON_ROOT"] ||= File.dirname('..') unless defined?(LENNON_ROOT)

module Sinatra
  
  module Lennon # John Lennon was the best songwriter ever.
    
    module Helpers
      include Rack::Utils
      alias_method :h, :escape_html
      
      # Wraps a conf object to be accessible from the other helpers
      def conf
        Conf.new
      end
      
      def theme
        conf.theme_name
      end
      
      # template helpers
      def get_sidebar
        "themes/#{theme}/_sidebar".to_sym
      end
      
      def get_footer
        "themes/#{theme}/_footer".to_sym
      end
      
      def get_header
        "themes/#{theme}/_header".to_sym
      end
      
      def get_post
        "themes/#{theme}/_post".to_sym
      end
      
      def get_comment
        "themes/#{theme}/_comment".to_sym
      end
      
      def get_comment_form
        "themes/#{theme}/_comment_form".to_sym
      end
      
      def css_directory
        "/themes/#{theme}/css"
      end
      
      def js_directory
        "/themes/#{theme}/js"
      end
      
      def nl_to_br(text)
        text.gsub(/\n/, '<br>')
      end
      
      def strip_tags(text)
        text.gsub(/<\/?[^>]*>/, "")
      end
      
      def nb_comments(nb)
        if nb == 1
          "one comment"
        elsif nb > 1
          "#{nb} comments"
        else
          "Leave a comment"
        end
      end
      
      def post_url(post)
        "#{conf.blog_url_prefix}/#{post.published_at.year}/#{post.published_at.month}/#{post.published_at.day}/#{post.slug}"
      end
      
      def escape_single_quotes(str)
        str.gsub('\\','\0\0').gsub('</','<\/').gsub(/\r\n|\n|\r/, "\\n").gsub(/["']/) { |m| "\\#{m}" }
      end
      
      def truncate_words(text, length = 100, end_string = ' ...')
        words = text.split()
        words[0..(length-1)].join(' ') + (words.length > length ? end_string : '')
      end
    
      def text_field(name, arg_value=nil, attrs={})
        if params.include? name
          value = params[name]
        else
          unless arg_value.nil?
            value = arg_value
          else
            value = ''
          end
        end
        "<input type='text' name='#{name}' value='#{value}' id='#{name}_field' #{attributize(attrs)}/>"
      end
      
      def text_area(name, arg_value=nil, attrs={})
        if params.include? name
          value = params[name]
        else
          unless arg_value.nil?
            value = arg_value
          else
            value = ''
          end
        end
        "<textarea name='#{name}' rows='8' id='#{name}_field' cols='40' #{attributize(attrs)}>#{value}</textarea>"
      end
      
      def checkbox(name, value, is_checked=false, attrs={})
        checked = "checked='checked'" if is_checked
        "<input type='checkbox' name='#{name}' value='#{value}' id='#{name}_checkbox_#{value}' #{checked} #{attributize(attrs)} />"
      end
      
      # Select field
      # Example: select 'date', :default=>1, :html=>{:id=>'pub_date_month'} :kv=>[[:key,1],[...]]
      def select(name, args)
        attrs = (args.has_key?(:html) ? args[:html] : {})
        key_val = (args.has_key?(:kv) ? args[:kv] : [])
        default = (args.has_key?(:default) ? args[:default] : nil)
        str = "<select name='#{name}' id='#{name}_field' #{attributize(attrs)}>"
        key_val.each do |k,v|
          str += "<option value='#{v}'#{" selected='selected'" if v == default}>"
          str += "#{k}</option>"
        end
        str += "</select>"
        str
      end
      
      def link_to(label, path, attrs={})
        "<a href='#{path}' #{attributize(attrs)}>#{label}</a>"
      end
      
      def delete_btn(label, path)
        <<-HTML
        <form method="post" action="#{ path }" onsubmit="return confirm('Are you sure?');">
          <input type="hidden" name="_method" value="delete" />
          <button type="submit">#{ label }</button>
        </form>
        HTML
      end
      
      def attributize(hash)
        ret = ''
        hash.each_pair do |att, val|
          ret += " #{att}='#{val}'"
        end
        ret
      end
      
      def partial(template, *args)
        options = args.extract_options!
        options.merge!(:layout => false)
        if collection = options.delete(:collection)
          collection.inject([]) do |buffer, member|
            buffer << erb(template, options.merge(
                                      :layout => false, 
                                      :locals => {template.to_sym => member}
                                    )
                         )
          end.join("\n")
        else
          erb(template, options)
        end
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
      app.set :sessions, true
      app.set :conf, Conf.new
      app.set :dbconf, YAML.load_file("#{app.root('.')}/config/database.yml")[app.environment.to_s]
      
      ActiveRecord::Base.establish_connection app.dbconf
      
      # Admin
      # 
      app.get '/admin/?' do
        if authorized?
          erb :"admin/admin", :layout=>:"admin/layout_admin"
        else
          redirect '/admin/login'
        end
      end
      
      app.get '/admin/login/?' do
        erb :"admin/admin_login", :layout=>:"admin/layout_admin"
      end
      
      app.post '/admin/login' do
        if params[:username] == app.conf.admin_user && params[:password] == app.conf.admin_pass
          session[:authorized] = true
          redirect '/admin'
        else
          session[:authorized] = false
          redirect '/admin/login'
        end
      end
      
      app.get '/admin/logout/?' do
        logout!
        redirect "#{app.conf.blog_url_prefix}/"
      end
      
      app.post '/admin/upload' do
        authorize!
        unless params[:upload] &&
               (tmpfile = params[:upload][:tempfile]) &&
               (name = params[:upload][:filename])
          @error = "No file selected"
          return @error
        end
        # TODO: check that we have the "image" folder already there before uploading
        directory = "public/uploads/images"
        path = File.join(directory, name)
        # We're using a "while" because a plain f.write(tmpfile.read) would use 
        # as much RAM as the size of the attachment.
        # Found here : http://www.ruby-forum.com/topic/193036
        while blk = tmpfile.read(65536)
          File.open(path, "a") { |f| f.write(blk) }
        end
        %Q"<script type='text/javascript'>
          var CKEditorFuncNum = #{params[:CKEditorFuncNum]};
          window.parent.CKEDITOR.tools.callFunction( CKEditorFuncNum, '/uploads/images/#{name}' );
        </script>"
      end
      
      app.get '/admin/uploaded_images' do
        authorize!
        @images = []
        basedir = "./public/uploads/images"
        contains = Dir.new(basedir).entries
        rejected = ['.', '..', '.DS_Store']
        @images = contains.reject {|f| rejected.include? f }
        erb :"admin/uploaded_images", :layout=>:"admin/layout_ckeditor"
      end
      
      # # # # # # # # # # # # # # # # # # # # # 
      # CRUD
      
      # POSTS
      
      # Create
      app.get '/admin/posts/add/?' do
        authorize!
        @post = Post.new
        @tags = Tag.all
        erb :"admin/admin_posts_add", :layout=>:"admin/layout_admin"
      end
      
      app.post '/admin/posts/add' do
        authorize!
        post = Post.new( :title => params[:title], :slug => params[:slug], :content=>params[:content], :published_at=>Time.now )
        if params[:post]
          tag_ids = params[:post][:tags]
        else
          tag_ids = []
        end
        tags = Tag.all(:conditions=>{:id=>(tag_ids)})
        post.tags = tags
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
        @posts = Post.all(:order=>'published_at DESC')
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
        @tags = Tag.all
        @post = Post.find(params[:id])
        erb :"admin/admin_posts_edit", :layout=>:"admin/layout_admin"
      end
      
      app.put '/admin/posts/:id' do
        authorize!
        post = Post.update( params[:id] , {
          :title=>params[:title],
          :slug=>params[:slug],
          :content=>params[:content],
          :published_at=>params[:published_at]
        })
        if params[:post]
          tag_ids = params[:post][:tags]
        else
          tag_ids = []
        end
        tags = Tag.all(:conditions=>{:id=>(tag_ids)})
        post.tags = tags
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

      # TAGS
      
      # Create
      app.get '/admin/tags/add/?' do
        authorize!
        erb :"admin/admin_tags_add", :layout=>:"admin/layout_admin"
      end
      
      app.post '/admin/tags/add' do
        authorize!
        tag = Tag.new( :name => params[:name], :slug => params[:slug])
        unless tag.save
          tag.errors
          @messages = tag.errors.full_messages
          erb :"admin/admin_tags_add", :layout=>:"admin/layout_admin"
        else
          redirect '/admin/tags'
        end
      end
      
      # Read
      app.get '/admin/tags/?' do
        authorize!
        @tags = Tag.all.reverse
        erb :"admin/admin_tags", :layout=>:"admin/layout_admin"
      end
      
      app.get '/admin/tags/:post_id/ajax/?' do
        authorize!
        @tags = Tag.all.reverse
        if params[:post_id]!= '0'
          @post = Post.find(params[:post_id])
        else
          @post = []
        end
        erb :"admin/admin_tags_ajax", :layout=>false
      end
      
      app.get '/admin/tags/:id' do
        authorize!
        @tag = Tag.find(params[:id])
        erb :"admin/admin_tag", :layout=>:"admin/layout_admin"
      end
      
      # Update
      app.get '/admin/tags/:id/edit' do 
        authorize!
        @tag = Tag.find(params[:id])
        erb :"admin/admin_tags_edit", :layout=>:"admin/layout_admin"
      end
      
      app.put '/admin/tags/:id' do
        authorize!
        tag = Tag.update( params[:id] , {
          :name=>params[:name],
          :slug=>params[:slug]
        })
        unless tag.save
          tag.errors
          @tag = Tag.find(params[:id])
          @messages = tag.errors.full_messages
          erb :"admin/admin_tags_edit", :layout=>:"admin/layout_admin"
        else
          redirect '/admin/tags'
        end
      end
      
      # Delete
      app.delete '/admin/tags/:id' do
        authorize!
        @tag = Tag.find(params[:id])
        @tag.destroy
        redirect '/admin/tags'
      end

      # Comment
      
      # Read
      app.get '/admin/comments/?' do
        authorize!
        @comments = Comment.all.reverse
        erb :"admin/admin_comments", :layout=>:"admin/layout_admin"
      end
            
      # Update
      app.get '/admin/comments/:id/edit' do 
        authorize!
        @comment = Comment.find(params[:id])
        erb :"admin/admin_comments_edit", :layout=>:"admin/layout_admin"
      end
      
      app.put '/admin/comments/:id' do
        authorize!
        comment = Comment.update( params[:id] , {
          :name=>params[:name],
          :website=>params[:website],
          :email=>params[:email],
          :is_approved=>params[:is_approved],
          :comment=>params[:comment]
        })
        unless comment.save
          comment.errors
          @comment = Comment.find(params[:id])
          @messages = comment.errors.full_messages
          erb :"admin/admin_comments_edit", :layout=>:"admin/layout_admin"
        else
          redirect '/admin/comments'
        end
      end
      
      # Delete
      app.delete '/admin/comments/:id' do
        authorize!
        @comment = Comment.find(params[:id])
        @comment.destroy
        redirect '/admin/comments'
      end


      # Option
      
      # Read
      app.get '/admin/options/?' do
        authorize!
        @options = Option.all.reverse
        erb :"admin/admin_options", :layout=>:"admin/layout_admin"
      end
      
      app.get '/admin/options/:id' do
        authorize!
        @options = Option.find(params[:id])
        erb :"admin/admin_option", :layout=>:"admin/layout_admin"
      end
      
      # Update
      app.get '/admin/options/:id/edit' do 
        authorize!
        @option = Option.find(params[:id])
        erb :"admin/admin_options_edit", :layout=>:"admin/layout_admin"
      end
      
      app.put '/admin/options/:id' do
        authorize!
        option = Option.update( params[:id] , {
          :option_name=>params[:option_name],
          :option_value=>params[:option_value]
        })
        unless option.save
          option.errors
          @option = Option.find(params[:id])
          @messages = option.errors.full_messages
          erb :"admin/admin_options_edit", :layout=>:"admin/layout_admin"
        else
          redirect '/admin/options'
        end
      end
      
      # Delete
      app.delete '/admin/options/:id' do
        authorize!
        @option = Option.find(params[:id])
        @option.destroy
        redirect '/admin/options'
      end
      
      
      # 404 error
      app.not_found do
        '<h1>I only found this 404 error :(</h1>'
      end
      
    end
    
  end
  
  register Lennon
end
