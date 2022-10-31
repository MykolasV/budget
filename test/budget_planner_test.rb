ENV["RACK_ENV"] = "test"

require 'simplecov'
SimpleCov.start

require 'minitest/autorun'
require "rack/test"

require 'minitest/reporters'
MiniTest::Reporters.use!

require_relative "../budget_planner"

class BudgetTest < Minitest::Test
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def session
    last_request.env["rack.session"]
  end

  def test_home
    get "/"
    assert_equal(302, last_response.status)

    get last_response["Location"]
    assert_equal(200, last_response.status)
    assert_equal("text/html;charset=utf-8", last_response["Content-Type"])
    assert_includes(last_response.body, '<h2>Income</h2>')
    assert_includes(last_response.body, '<form method="post" action="/income" id="save_income">')
    assert_includes(last_response.body, '<a herf="#" class="add_input">+ Income</a>')
    assert_includes(last_response.body, '<button type="submit">Save</button>')
  end

  def test_income
    get "/income"
    assert_equal(200, last_response.status)
    assert_equal("text/html;charset=utf-8", last_response["Content-Type"])
    assert_includes(last_response.body, '<h2>Income</h2>')
    assert_includes(last_response.body, '<form method="post" action="/income" id="save_income">')
    assert_includes(last_response.body, '<a herf="#" class="add_input">+ Income</a>')
    assert_includes(last_response.body, '<button type="submit">Save</button>')
  end

  def test_income_with_income
    get "/income", {}, { "rack.session" => { income: { "1" => { name: "salary", amount: "700.00", occurance: "fortnightly" } } } }
    assert_equal(302, last_response.status)
    assert_equal('Income saved. You will be able to edit it later.', session[:success_message])

    get last_response["Location"]
    assert_equal(200, last_response.status)
    assert_equal("text/html;charset=utf-8", last_response["Content-Type"])
    assert_includes(last_response.body, '<h2>Expenses</h2>')
    assert_includes(last_response.body, '<form id="add_category">')
    assert_includes(last_response.body, '<form method="post" action="/expenses" id="save_expenses">')
    assert_includes(last_response.body, '<a herf="#" class="add_input">+ Expense</a>')
    assert_includes(last_response.body, '<button type="submit">Save</button>')
  end

  def test_save_income
    post "/income", { income_name_1: "salary", income_amount_1: "700.00", income_occurance_1: "fortnightly" }
    assert_equal(302, last_response.status)
    assert_equal("Income saved. You will be able to edit it later.", session[:success_message])
    
    get last_response["Location"]
    assert_equal(200, last_response.status)
    assert_equal("text/html;charset=utf-8", last_response["Content-Type"])
    assert_includes(last_response.body, '<h2>Expenses</h2>')
    assert_includes(last_response.body, '<form id="add_category">')
    assert_includes(last_response.body, '<form method="post" action="/expenses" id="save_expenses">')
    assert_includes(last_response.body, '<a herf="#" class="add_input">+ Expense</a>')
    assert_includes(last_response.body, '<button type="submit">Save</button>')
  end

  def test_expenses
    get "/expenses", {}, { "rack.session" => { income: { "1" => { name: "salary", amount: "700.00", occurance: "fortnightly" } } } }
    assert_equal(200, last_response.status)
    assert_equal("text/html;charset=utf-8", last_response["Content-Type"])
    assert_includes(last_response.body, '<h2>Expenses</h2>')
    assert_includes(last_response.body, '<form id="add_category">')
    assert_includes(last_response.body, '<form method="post" action="/expenses" id="save_expenses">')
    assert_includes(last_response.body, '<a herf="#" class="add_input">+ Expense</a>')
    assert_includes(last_response.body, '<button type="submit">Save</button>')
  end

  def test_expenses_with_no_income
    get "/expenses"
    assert_equal(302, last_response.status)
    assert_includes(session[:error_messages], 'Please provide some details about your income.')

    get last_response["Location"]
    assert_equal(200, last_response.status)
    assert_equal("text/html;charset=utf-8", last_response["Content-Type"])
    assert_includes(last_response.body, '<form method="post" action="/income" id="save_income">')
  end

  def test_expenses_with_expenses
    get "/expenses", {}, { 
      "rack.session" => { 
        income: { "1" => { name: "salary", amount: "700.00", occurance: "fortnightly" } },
        expenses: { "essentials" => { "1" => { name: "rent", amount: "462.00", occurance: "monthly" } } }
      }
    }

    assert_equal(302, last_response.status)
    assert_equal('Expenses saved.', session[:success_message])

    get last_response["Location"]
    assert_equal(200, last_response.status)
    assert_equal("text/html;charset=utf-8", last_response["Content-Type"])
    assert_includes(last_response.body, '<h1>Budget Planner</h1>')
    assert_includes(last_response.body, '<h2>Summary</h2>')
    assert_includes(last_response.body, '<select id="occurance" data-occurance="monthly">')
    assert_includes(last_response.body, '<option value="monthly" selected>Monthly</option>')
    assert_includes(last_response.body, '<h3>Income: £<span class="amount" data-monthly-amount="1520.83">1520.83</span></h3>')
    assert_includes(last_response.body, '<h3>Expenses: £<span class="amount" data-monthly-amount="462.0">462.0</span></h3>')
    assert_includes(last_response.body, '<h3>Spare Cash: £<span class="amount" data-monthly-amount="1058.83">1058.83</span></h3>')
  end

  def test_save_expenses
    post "/expenses",
    {
      category_name_1: "essentials", essentials_name_1: "rent", essentials_amount_1: "462.00", essentials_occurance_1: "monthly"
    },
    {
      "rack.session" => { income: { "1" => { name: "salary", amount: "700.00", occurance: "fortnightly" } } }
    }

    assert_equal(302, last_response.status)
    assert_equal("Expenses saved.", session[:success_message])

    get last_response["Location"]
    assert_equal(200, last_response.status)
    assert_equal("text/html;charset=utf-8", last_response["Content-Type"])
    assert_includes(last_response.body, '<h1>Budget Planner</h1>')
    assert_includes(last_response.body, '<h2>Summary</h2>')
    assert_includes(last_response.body, '<select id="occurance" data-occurance="monthly">')
    assert_includes(last_response.body, '<option value="monthly" selected>Monthly</option>')
    assert_includes(last_response.body, '<h3>Income: £<span class="amount" data-monthly-amount="1520.83">1520.83</span></h3>')
    assert_includes(last_response.body, '<h3>Expenses: £<span class="amount" data-monthly-amount="462.0">462.0</span></h3>')
    assert_includes(last_response.body, '<h3>Spare Cash: £<span class="amount" data-monthly-amount="1058.83">1058.83</span></h3>')
  end

  def test_summary_with_no_income
    get "/summary"
    assert_equal(302, last_response.status)
    assert_includes(session[:error_messages], 'Please provide some details about your income.')

    get last_response["Location"]
    assert_equal(200, last_response.status)
    assert_equal("text/html;charset=utf-8", last_response["Content-Type"])
    assert_includes(last_response.body, '<form method="post" action="/income" id="save_income">')
    assert_includes(last_response.body, '<a herf="#" class="add_input">+ Income</a>')
    assert_includes(last_response.body, '<button type="submit">Save</button>')
  end

  def test_summary_with_no_expenses
    get "/summary", {}, { "rack.session" => { income: { "1" => { name: "salary", amount: "700.00", occurance: "fortnightly" } } } }
    assert_equal(302, last_response.status)
    assert_includes(session[:error_messages], 'Please provide some details about your expenses.')

    get last_response["Location"]
    assert_equal(200, last_response.status)
    assert_equal("text/html;charset=utf-8", last_response["Content-Type"])
    assert_includes(last_response.body, '<form id="add_category">')
    assert_includes(last_response.body, '<form method="post" action="/expenses" id="save_expenses">')
    assert_includes(last_response.body, '<a herf="#" class="add_input">+ Expense</a>')
    assert_includes(last_response.body, '<button type="submit">Save</button>')
  end

  def test_summary  
    get "/summary", {}, { 
      "rack.session" => { 
        income: { "1" => { name: "salary", amount: "700.00", occurance: "fortnightly" } },
        expenses: { "essentials" => { "1" => { name: "rent", amount: "462.00", occurance: "monthly" } } }
      }
    }

    assert_equal(200, last_response.status)
    assert_equal("text/html;charset=utf-8", last_response["Content-Type"])
    assert_includes(last_response.body, '<h1>Budget Planner</h1>')
    assert_includes(last_response.body, '<h2>Summary</h2>')
    assert_includes(last_response.body, '<select id="occurance" data-occurance="monthly">')
    assert_includes(last_response.body, '<option value="monthly" selected>Monthly</option>')
    assert_includes(last_response.body, '<h3>Income: £<span class="amount" data-monthly-amount="1520.83">1520.83</span></h3>')
    assert_includes(last_response.body, '<h3>Expenses: £<span class="amount" data-monthly-amount="462.0">462.0</span></h3>')
    assert_includes(last_response.body, '<h3>Spare Cash: £<span class="amount" data-monthly-amount="1058.83">1058.83</span></h3>')
  end

  def test_edit_income
    get "/income/edit", {}, { 
      "rack.session" => { 
        income: { "1" => { name: "salary", amount: "700.00", occurance: "fortnightly" } },
        expenses: { "essentials" => { "1" => { name: "rent", amount: "462.00", occurance: "monthly" } } }
      }
    }

    assert_equal(200, last_response.status)
    assert_equal("text/html;charset=utf-8", last_response["Content-Type"])
    assert_includes(last_response.body, '<h2>Edit Income</h2>')
    assert_includes(last_response.body, '<form method="post" action="/update_income" id="save_income">')
    assert_includes(last_response.body, '<label for="income_name_1">Income</label>')
    assert_includes(last_response.body, '<input type="text" id="income_name_1" name="income_name_1" value="salary" data-previous-value="salary">')
    assert_includes(last_response.body, '<label for="income_amount_1">Amount</label>')
    assert_includes(last_response.body, '<input type="number" id="income_amount_1" name="income_amount_1" value="700.00" placeholder="£0.00" min=".01" step=".01">')
    assert_includes(last_response.body, '<select id="income_occurance_1" name="income_occurance_1">')
    assert_includes(last_response.body, '<option value="fortnightly" selected>Fortnightly</option>')
  end

  def test_edit_income_without_income
    get "/income/edit"
    assert_equal(302, last_response.status)
    assert_includes(session[:error_messages], 'Please provide some details about your income.')

    get last_response["Location"]
    assert_equal(200, last_response.status)
    assert_equal("text/html;charset=utf-8", last_response["Content-Type"])
    assert_includes(last_response.body, '<form method="post" action="/income" id="save_income">')
  end

  def test_edit_income_without_expenses
    get "income/edit", {}, { "rack.session" => { income: { "1" => { name: "salary", amount: "700.00", occurance: "fortnightly" } } } }
    assert_equal(302, last_response.status)
    assert_includes(session[:error_messages], 'Please provide some details about your expenses.')

    get last_response["Location"]
    assert_equal(200, last_response.status)
    assert_equal("text/html;charset=utf-8", last_response["Content-Type"])
    assert_includes(last_response.body, '<form method="post" action="/expenses" id="save_expenses">')
  end

  def test_update_income
    post "/update_income",
    {
      income_name_1: "royalties", income_amount_1: "700.00", income_occurance_1: "fortnightly" 
    },
    { 
      "rack.session" => { 
        income: { "1" => { name: "salary", amount: "700.00", occurance: "fortnightly" } },
        expenses: { "essentials" => { "1" => { name: "rent", amount: "462.00", occurance: "monthly" } } }
      }
    }

    assert_equal(302, last_response.status)
    assert_equal('Income updated.', session[:success_message])

    get last_response["Location"]
    assert_equal(200, last_response.status)
    assert_equal("text/html;charset=utf-8", last_response["Content-Type"])
    assert_includes(last_response.body, '<h2>Summary</h2>')
    assert_includes(last_response.body, '<h3>Income: £<span class="amount" data-monthly-amount="1520.83">1520.83</span></h3>')
    refute_includes(last_response.body, '<dt>Salary</dt>')
    assert_includes(last_response.body, '<dt>Royalties</dt>')
  end

  def test_edit_expenses
    get "/expenses/edit", {}, { 
      "rack.session" => { 
        income: { "1" => { name: "salary", amount: "700.00", occurance: "fortnightly" } },
        expenses: { "essentials" => { "1" => { name: "rent", amount: "462.00", occurance: "monthly" } } }
      }
    }

    assert_equal(200, last_response.status)
    assert_equal("text/html;charset=utf-8", last_response["Content-Type"])
    assert_includes(last_response.body, '<h2>Edit Expenses</h2>')
    assert_includes(last_response.body, '<form id="add_category">')
    assert_includes(last_response.body, '<form method="post" action="/update_expenses" id="save_expenses">')
    assert_includes(last_response.body, '<a herf="#" class="add_input">+ Expense</a>')
    assert_includes(last_response.body, '<button type="submit">Save</button>')
  end

  def test_edit_expenses_without_income
    get "/expenses/edit"
    assert_equal(302, last_response.status)
    assert_includes(session[:error_messages], 'Please provide some details about your income.')

    get last_response["Location"]
    assert_equal(200, last_response.status)
    assert_equal("text/html;charset=utf-8", last_response["Content-Type"])
    assert_includes(last_response.body, '<form method="post" action="/income" id="save_income">')
  end

  def test_edit_expenses_without_expenses
    get "/expenses/edit", {}, { "rack.session" => { income: { "1" => { name: "salary", amount: "700.00", occurance: "fortnightly" } } } }
    assert_equal(302, last_response.status)
    assert_includes(session[:error_messages], 'Please provide some details about your expenses.')

    get last_response["Location"]
    assert_equal(200, last_response.status)
    assert_equal("text/html;charset=utf-8", last_response["Content-Type"])
    assert_includes(last_response.body, '<form method="post" action="/expenses" id="save_expenses">')
  end

  def test_update_expenses
    post "/update_expenses",
    {
      category_name_1: "other", other_name_1: "transport", other_amount_1: "40.00", other_occurance_1: "weekly"
    },
    { 
      "rack.session" => { 
        income: { "1" => { name: "salary", amount: "700.00", occurance: "fortnightly" } },
        expenses: { "essentials" => { "1" => { name: "rent", amount: "462.00", occurance: "monthly" } } }
      }
    }

    assert_equal(302, last_response.status)
    assert_equal('Expenses updated.', session[:success_message])

    get last_response["Location"]
    assert_equal(200, last_response.status)
    assert_equal("text/html;charset=utf-8", last_response["Content-Type"])
    assert_includes(last_response.body, '<h2>Summary</h2>')
    assert_includes(last_response.body, '<h3>Expenses: £<span class="amount" data-monthly-amount="173.81">173.81</span></h3>')
    assert_includes(last_response.body, "<dt class=\"category\">Other: £<span class='amount' data-monthly-amount='173.81'>173.81</span></dt>")
    refute_includes(last_response.body, "<dt class=\"category\">Essentials: £<span class='amount' data-monthly-amount='462.00'>462.00</span></dt>")
    assert_includes(last_response.body, '<dt>Transport</dt>')
    refute_includes(last_response.body, '<dt>Rent</dt>')
  end
end
