require 'sidekiq'

Sidekiq.configure_server do |config|
  config.redis = { url: 'redis://redistogo:c5944fb2b5a9501471166f451a8f04e8@ray.redistogo.com:10030/' }
end

require 'sidekiq/web'
require 'sidekiq/failures'
run Sidekiq::Web
