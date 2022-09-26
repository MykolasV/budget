require 'sinatra'
require 'sinatra/reloader'
require 'tilt/erubis'

configure do
  enable :sessions
  set :session_secret, 'secret'
end

before do
  session[:income] ||= []
end

get "/income" do
  erb :income_form, layout: :layout 
end
