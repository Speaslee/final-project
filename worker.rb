
class MusicWorker
  include Sidekiq::Worker

  def perform path, name
  cmd = "FILEPATH=#{path} NAME=#{name} rp5 run visualizer.rb"
  puts cmd
  `#{cmd}`
  end

end
