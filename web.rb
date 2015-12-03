require 'sinatra/base'
require 'tilt/erb'

class Web < Sinatra::Base
    set :logging, true
    get '/' do
      erb :index
    end

  end
Web.run!
