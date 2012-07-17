require 'sinatra'
require 'redis'




helpers do
  include Rack::Utils
  alias_method :h, :escape_html
  
  def startRedis
    uri = URI.parse('redis://redistogo:b6a74f344b75d53eceb91b72f2f7fe64@chubb.redistogo.com:9259/')
    @redis = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
  end
  
  def cleanup
    @redis.quit
  end
  
  def size
    startRedis
    @redis.dbsize
    cleanup
  end
  
  def getURL
    startRedis
    @redis.get "links:#{params[:shortcode]}"
    cleanup
  end
  
  def setURL(url)
    startRedis
    @shortcode = random_string(5)
    @redis.setnx "links:#{@shortcode}", url
    cleanup
  end
  
  def random_string(length)
    rand(36**length).to_s(36)
  end
end

get '/' do
  erb :index
end

post '/' do
  if params[:url] and not params[:url].empty?
    setURL(params[:url])
  end
  erb :index
end

get '/:shortcode' do
  redirect getURL || '/', 301
end
