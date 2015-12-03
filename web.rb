require 'sinatra/base'
class Web < Sinatra::Base
    set :logging, true
    get '/' do
      print 'hello world'
    end

  end
