
class MusicWorker
  include Sidekiq::Worker
  def perform(name)
    puts name
  end

end
