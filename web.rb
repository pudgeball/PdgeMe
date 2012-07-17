require 'sinatra'
require 'redis'


uri = URI.parse('redis://redistogo:b6a74f344b75d53eceb91b72f2f7fe64@chubb.redistogo.com:9259/')
redis = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)

helpers do
  include Rack::Utils
  alias_method :h, :escape_html
  
  def random_string(length)
    rand(36**length).to_s(36)
  end
end

get '/' do
  erb :index
end

post '/' do
  if params[:url] and not params[:url].empty?
    @shortcode = random_string(5)
    redis.setnx "links:#{@shortcode}", params[:url]
  end
  erb :index
end

get '/:shortcode' do
  @url = redis.get "links:#{params[:shortcode]}"
  redirect @url || '/', 301
end
