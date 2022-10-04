require 'sinatra'
require 'sinatra/reloader'
require 'tilt/erubis'

configure do
  enable :sessions
  set :session_secret, 'secret'
end

before do
  session[:income] ||= []
  session[:expenses] ||= {}
end

# Render the income form
get "/income" do
  erb :income_form, layout: :layout 
end

# Submit information about income
post "/income" do
  income_names = params.keys.select { |key| key.start_with?('income_name') }

  empty_input = false
  name_exists = false
  income_names.each do |income_name|
    income_number    = income_name.split("_").last
    income_name      = params["income_name_#{income_number}"]
    income_amount    = params["income_amount_#{income_number}"]
    income_occurance = params["income_occurance_#{income_number}"]

    if income_name == '' || income_amount == ''
      empty_input = true
      break
    end

    if session[:income].any? { |income| income[:name] == income_name }
      name_exists = true
      break
    end

    session[:income] << {
      name: income_name,
      amount: income_amount,
      occurance: income_occurance
    }
  end

  if empty_input
    session[:income] = []
    session[:error] = "Please provide the missing details."
    erb :income_form, layout: :layout
  elsif name_exists
    session[:income] = []
    session[:error] = "Income names must be unique."
    erb :income_form, layout: :layout
  else
    session[:success] = "Income saved. You will be able to edit it later."
    redirect "/expenses"
  end
end

# Render the expenses form
get "/expenses" do 
  erb :expenses_form, layout: :layout
end

# Submit information about expenses
post "/expenses" do
  if params.any? { |_, value| value.strip == "" }
    session[:error] = "Please provide the missing details"
    erb :expenses_form, layout: :layout
  else
    categories = params.select { |key, value| key.start_with?("category_name") }.values
    categories.each do |category|
      session[:expenses][category] = []

      params.each do |key, value|
        if key.include?(category)
          field, number = key.delete_prefix("#{category}_").split("_")
          session[:expenses][category][number.to_i - 1] ||= {}
          session[:expenses][category][number.to_i - 1][field] = value
        end
      end
    end

    redirect "/summary"
  end
end

get "/summary" do
  "summary"
end
