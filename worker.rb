class MusicWorker
  include Sidekiq::Worker

  def perform path, name
    Visualizer.run!(path, name)
  end

end

MusicWorker.new.perform("https://s3.amazonaws.com/pantonely/uploads/song/songfile/1/kite.mp3", "kite.mp3")
