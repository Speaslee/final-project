require 'sidekiq'
require 'sidekiq-ffmpeg'
class EncodeJob < Sidekiq::Ffmpeg::BaseJob

  def on_progress(progress, extra_data = {})
    p progress
  end

  def on_complete(encoder, extra_data = {})
    puts "complete"
  end
end
