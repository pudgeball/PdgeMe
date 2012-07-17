require 'sinatra'
require 'redis'


uri = URI.parse('redis://nickmcguire:3cd38c7b1847ae2e35cdcb878c22b063@chubb.redistogo.com:9261/')
redis = Redis.new(:host => "localhost", :port => '6789')

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

post "/" do
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
