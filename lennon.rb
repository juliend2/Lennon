module Sinatra
  
  module Lennon # John Lennon was the best songwriter ever.
    
    module Helpers
      
      def page_link(label, path)
        "<a href='#{path}'>#{label}</a>"
      end

      def paginate(max_pages, current)
        links = []
        current = current || '1'
        1.upto max_pages do |i|
          if i.to_s == current
            links << i
          else
            links << page_link(i, "/page/#{i}")
          end
        end
        links.join(', ')
      end
      
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
    end
  end
  
  register Lennon
end
