require 'sinatra/base'
require 'tilt/erb'

class Web < Sinatra::Base
    set :logging, true
    get '/' do
      erb :list
    end

  end
Web.run!
