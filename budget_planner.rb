require 'sinatra'
require 'sinatra/reloader'
require 'tilt/erubis'

get "/" do
  erb :income_form, layout: :layout 
end
