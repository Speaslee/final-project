class MusicWorker
  include Sidekiq::Worker
  def perform path, name
    Visualizer.run!(path, name)
  end

end
