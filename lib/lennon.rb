LENNON_ROOT = ENV["LENNON_ROOT"] ||= File.dirname('..') unless defined?(LENNON_ROOT)

module Sinatra
  
  module Lennon # John Lennon was the best songwriter ever.
    
    module Helpers
      
      ##
      # Helper method for file references.
      # (Stolen from Padrino-framework)
      #
      # ==== Examples
      #
      #   # Referencing a file in config called settings.yml
      #   root("config", "settings.yml")
      #   # returns LENNON_ROOT + "/config/setting.yml"
      # 
      def root(*args)
        File.expand_path(File.join(LENNON_ROOT, *args))
      end
      
      def link_to(label, path)
        "<a href='#{path}'>#{label}</a>"
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
      app.set :conf, YAML.load_file("#{app.root('.')}/config.yml")[app.environment.to_s]
      
      MongoMapper.connection = Mongo::Connection.new(app.conf['mongo_host'], app.conf['mongo_port'], :auto_reconnect => true)
      MongoMapper.database = app.conf['mongo_db']
      MongoMapper.database.authenticate(app.conf['mongo_user'], app.conf['mongo_pass'])
      
      # Admin
      # 
      app.get '/admin' do
        if authorized?
          "Hi. I know you."
        else
          "Hi. We haven't met. <a href='/admin/login'>Login, please.</a>"
        end
      end
      
      app.get '/admin/login' do
        erb :admin_login
      end
      
      app.post '/admin/login' do
        if params[:user] == options.username && params[:pass] == options.password
          session[:authorized] = true
          redirect '/'
        else
          session[:authorized] = false
          redirect '/admin/login'
        end
      end
      
      app.get '/path' do
        options.root_path
      end
      
      app.not_found do
        '<h1>I only found this 404 error :(</h1>'
      end
      
    end
    
  end
  
  register Lennon
end
