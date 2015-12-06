# require 'sidekiq'
# require 'sinatra'
# require 'redis'
# require 'sidekiq/api'
#
#redis-server "/Users/sophiapeaslee/Desktop/Programs/finalproject/redis.conf"

Sidekiq.configure_client do |config|
  config.redis = { url: 'redis://redistogo:c5944fb2b5a9501471166f451a8f04e8@ray.redistogo.com:10030/' }
end


class MusicWorker
  include Sidekiq::Worker

  def perform path, name
  cmd = "FILEPATH=#{path} NAME=#{name} rp5 run visualizer.rb"
  puts cmd
  puts`#{cmd}`
  end
end




  # get '/' do
  #   stats = Sidekiq::Stats.new
  #   @failed = stats.failed
  #   @processed = stats.processed
  #   erb :index
  # end
