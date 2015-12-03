require 'sidekiq'
require 'sinatra'
require 'redis'
require 'sidekiq/api'

Sidekiq.configure_server do |config|
  config.redis = { :namespace => 'x' }
end

class MusicWorker
  include Sidekiq::Worker

  def perform path, name
  cmd = "FILEPATH=#{path} NAME=#{name} rp5 run visualizer.rb"
  puts cmd
  `#{cmd}`
  end
end

  get '/' do
    stats = Sidekiq::Stats.new
    @failed = stats.failed
    @processed = stats.processed
    erb :index
  end



#MusicWorker.new.perform("https://s3.amazonaws.com/pantonely/uploads/song/songfile/1/kite.mp3", "kite.mp3")
