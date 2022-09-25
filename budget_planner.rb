require 'sinatra'
require 'sinatra/reloader'
require 'tilt/erubis'

get "/income_form" do
  erb :income_form, layout: :layout 
end
