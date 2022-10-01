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

post "/income" do
  income_names = params.keys.select { |key| key.start_with?('income_name') }

  invalid_input = false
  income_names.each do |income_name|
    income_name = income_name.strip
    income_number    = income_name.split("_").last
    income_amount    = params["income_amount_#{income_number}"]
    income_occurance = params["income_occurance_#{income_number}"]

    if income_name == '' || income_amount == ''
      invalid_input = true
      break
    end

    session[:income] << {
      income: income_name,
      amount: income_amount,
      occurance: income_occurance
    }
  end

  if invalid_input
    session[:income] = []
    session[:error] = "Please provide the missing details."
    erb :income_form, layout: :layout
  else
    session[:success] = "Income saved. You will be able to edit it later."
    redirect "/expenses"
  end
end

get "/expenses" do 
  session[:income].to_s
end
