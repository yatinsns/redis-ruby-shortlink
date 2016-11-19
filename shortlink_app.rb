require 'sinatra'
require 'redis'

redis = Redis.new

# In sinatra, you can specify helpers that are executed every time
# one of your routes is run.

helpers do
  include Rack::Utils
  alias_method :h, :escape_html

  def random_string(length)
    rand(36**length).to_s(36)
  end
end

# Whenever a client makes a GET request to /, it just renders index.erb page.

get '/' do
  erb :index
end

post '/' do
  if params[:url] and not params[:url].empty?
    @shortcode = random_string 5
    redis.setnx "links:#{@shortcode}", params[:url]
  end
  erb :index
end

# This route introduces URL parameter.
# For example when a client visits '/foobar',
# the :shortcode part of route matches 'foobar'.

get '/:shortcode' do
  @url = redis.get "links:#{params[:shortcode]}"
  redirect @url || '/'
end
