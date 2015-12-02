
class MusicWorker
  include Sidekiq::Worker

  def perform path, name
  cmd = "FILEPATH=#{path} NAME=#{name} rp5 run visualizer.rb"
  puts cmd
  `#{cmd}`
  end

end

MusicWorker.new.perform("https://s3.amazonaws.com/pantonely/uploads/song/songfile/1/kite.mp3", "kite.mp3")
