require "sinatra"
require "sinatra/reloader"
require "tilt/erubis"

configure do
  enable :sessions
  set :session_secret, "secret"
end

before do
  session[:income] ||= {}
  session[:expenses] ||= {}
  session[:error_messages] ||= []
end

# Render the income form
get "/income" do
  if session[:income].length > 0
    session[:success_message] = "Income saved. You will be able to edit it later."
    redirect "/expenses"
  end

  erb :income_form, layout: :layout
end

# Return error messages if any values are invalid
def error_messages_for_income(income)
  messages = []

  if income.any? { |_, inc| inc.any? { |_, value| value == "" } }
    messages << "Please provide the missing details."
  end

  income_names = income.map { |_, inc| inc["name"] }
  if income_names.any? { |name| name != "" && income_names.count(name) > 1 }
    messages << "Income names must be unique."
  end

  messages
end

# Submit information about income
post "/income" do
  income = {}

  params.each do |key, value|
    number = key.split("_").last
    field = key.split("_")[-2]
    income[number] ||= {}
    income[number][field] = value.strip
  end

  error_messages = error_messages_for_income(income)
  if error_messages.empty?
    session[:income] = income
    session[:success_message] = "Income saved. You will be able to edit it later."
    redirect "/expenses"
  else
    session[:error_messages] = error_messages
    erb :income_form, layout: :layout
  end
end

# Render the expenses form
get "/expenses" do
  if session[:income].length <= 0
    session[:error_messages] << "Please provide some details about your income."
    redirect "/income"
  end

  if session[:expenses].length > 0
    session[:success_message] = "Expenses saved."
    redirect "/summary"
  end

  erb :expenses_form, layout: :layout
end

# Return error messages if any values are invalid
def error_messages_for_expenses(expenses_by_categories)
  messages = []

  categories = expenses_by_categories.keys
  expenses   = expenses_by_categories.values.map { |expenses| expenses.values }

  if categories.any? { |category| category == "" }
    messages << "Please provide the missing category names"
  end

  if categories.any? { |category| category != "" && categories.count(category) > 1 } 
    messages << "Category names must be unique."
  end

  if expenses.flatten.any? { |expense| expense.any? { |_, value| value == "" } }
    messages << "Please provide the missing details for expenses"
  end

  if expenses.any? do |exp|
       expense_names = exp.map { |expense| expense["name"] }
       expense_names.any? { |name| name != "" && expense_names.count(name) > 1 }
     end
    messages << "Expense names must be unique."
  end

  messages
end

# Submit information about expenses
post "/expenses" do
  categories = params.select { |key, value| key.start_with?("category_name") }.values
  expenses_by_categories = categories.each_with_object({}) do |category, obj|
    obj[category] = {}

    params.each do |key, value|
      if !key.start_with?("category_name") && key.start_with?(category)
        number = key.split("_").last
        field  = key.split("_")[-2]

        obj[category][number] ||= {}
        obj[category][number][field] = value.strip
      end
    end
  end

  error_messages = error_messages_for_expenses(expenses_by_categories)

  if error_messages.empty?
    session[:expenses] = expenses_by_categories
    session[:success_message] = "Expenses saved."
    redirect "/summary"
  else
    session[:error_messages] = error_messages
    erb :expenses_form, layout: :layout
  end
end

get "/summary" do
  "summary"
end
