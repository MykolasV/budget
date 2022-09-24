require 'sinatra'
require 'sinatra/reloader'
require 'tilt/erubis'

get "/" do
  erb "Welcome to the application", layout: :layout 
end
