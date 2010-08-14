%w{
  rubygems
  sinatra
  lennon
}.each { |r| require r }

set :sessions, true

get '/' do
  'hello world'
end

get '/admin' do
  if authorized?
    "Hi. I know you."
  else
    "Hi. We haven't met. <a href='/admin/login'>Login, please.</a>"
  end
end