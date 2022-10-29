require "sinatra"
require "sinatra/reloader"
require "tilt/erubis"
require "date"

configure do
  enable :sessions
  set :session_secret, "secret"
  set :erb, :escape_html => true
end

helpers do
  def format_title(name)
    name.split(/_| /).map { |str| str.capitalize }.join(" ")
  end
end

before do
  session[:income] ||= {}
  session[:expenses] ||= {}
  session[:error_messages] ||= []
end

# Return error messages if any values are invalid
def error_messages_for_income(income)
  messages = []

  if income.any? { |_, inc| inc.any? { |_, value| value == "" } }
    messages << "Please provide the missing details."
  end

  income_names = income.map { |_, inc| inc[:name] }
  if income_names.any? { |name| name != "" && income_names.count(name) > 1 }
    messages << "Income names must be unique."
  end

  messages
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
       expense_names = exp.map { |expense| expense[:name] }
       expense_names.any? { |name| name != "" && expense_names.count(name) > 1 }
     end
    messages << "Expense names must be unique."
  end

  messages
end

# Return the converted monthly amount
def to_monthly(amount, occurance)
  days_in_year   = Date.today.leap? ? 366 : 365
  weeks_in_year  = days_in_year / 7.0

  if occurance == 'daily'
    amount = (amount * days_in_year) / 12
  elsif occurance == 'weekly'
    amount = (amount * weeks_in_year) / 12
  elsif occurance == 'fortnightly'
    amount = ((amount / 2) * weeks_in_year) / 12
  elsif occurance == 'quarterly'
    amount = (amount * 4) / 12
  elsif occurance == 'six_monthly'
    amount = (amount * 2) / 12
  elsif occurance == 'yearly'
    amount = amount / 12
  end

  amount.round(2)
end

# Redirect to income page
get "/" do
  redirect "/income"
end

# Render the income form
get "/income" do
  if session[:income].length > 0
    session[:success_message] = "Income saved. You will be able to edit it later."
    redirect "/expenses"
  end

  erb :income, layout: :layout
end

# Submit information about income
post "/income" do
  income = {}

  params.each do |key, value|
    number = key.split("_").last
    field = key.split("_")[-2]
    income[number] ||= {}
    income[number][field.to_sym] = value.strip
  end

  error_messages = error_messages_for_income(income)
  if error_messages.empty?
    session[:income] = income
    session[:success_message] = "Income saved. You will be able to edit it later."
    redirect "/expenses"
  else
    session[:error_messages] = error_messages
    erb :income, layout: :layout
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

  erb :expenses, layout: :layout
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
        obj[category][number][field.to_sym] = value.strip
      end
    end
  end

  error_messages = error_messages_for_expenses(expenses_by_categories)

  if error_messages.empty?
    session[:expenses] = expenses_by_categories
    redirect "/summary"
  else
    session[:error_messages] = error_messages
    erb :expenses, layout: :layout
  end
end

get "/summary" do
  if session[:income].length <= 0
    session[:error_messages] << "Please provide some details about your income."
    redirect "/income"
  end

  if (session[:expenses].length <= 0)
    session[:error_messages] << "Please provide some details about your expenses."
    redirect "/expenses"
  end

  @monthly_income = session[:income].values.map { |income| { name: income[:name], amount: to_monthly(income[:amount].to_f, income[:occurance]) } }
  @monthly_income_total = @monthly_income.reduce(0) { |sum, income| sum + income[:amount] }
  @monthly_expenses = session[:expenses].keys.each_with_object({}) do |category, obj|
    obj[category] = session[:expenses][category].values.map { |expense| { name: expense[:name], amount: to_monthly(expense[:amount].to_f, expense[:occurance]) } }
  end
  @monthly_expenses_total = @monthly_expenses.values.flatten.reduce(0) { |sum, expense| sum + expense[:amount] }
  @monthly_spare = (@monthly_income_total - @monthly_expenses_total).round(2)

  erb :summary, layout: :layout
end

get "/income/edit" do
  @income = session[:income]

  erb :edit_income, layout: :layout
end

post "/update_income" do
  income = {}

  params.each do |key, value|
    number = key.split("_").last
    field = key.split("_")[-2]
    income[number] ||= {}
    income[number][field.to_sym] = value.strip
  end

  error_messages = error_messages_for_income(income)
  if error_messages.empty?
    session[:income] = income
    session[:success_message] = "Income updated."
    redirect "/summary"
  else
    session[:error_messages] = error_messages
    erb :edit_income, layout: :layout
  end
end

get "/expenses/edit" do
  @expenses = session[:expenses]

  erb :edit_expenses, layout: :layout
end

post "/update_expenses" do
  categories = params.select { |key, value| key.start_with?("category_name") }.values
  expenses_by_categories = categories.each_with_object({}) do |category, obj|
    obj[category] = {}

    params.each do |key, value|
      if !key.start_with?("category_name") && key.start_with?(category)
        number = key.split("_").last
        field  = key.split("_")[-2]

        obj[category][number] ||= {}
        obj[category][number][field.to_sym] = value.strip
      end
    end
  end

  error_messages = error_messages_for_expenses(expenses_by_categories)

  if error_messages.empty?
    session[:expenses] = expenses_by_categories
    session[:success_message] = "Expenses updated."
    redirect "/summary"
  else
    session[:error_messages] = error_messages
    erb :edit_expenses, layout: :layout
  end
end
