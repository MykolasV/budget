ENV["RACK_ENV"] = "test"

require "minitest/autorun"
require "rack/test"

require_relative "../budget_planner"

class BudgetTest < Minitest::Test
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def test_income
    get "/income"
    assert_equal(200, last_response.status)
    assert_equal("text/html;charset=utf-8", last_response["Content-Type"])
    assert_includes(last_response.body, '<form method="post" action="/income" id="save_income">')
    assert_includes(last_response.body, '<a herf="#" class="add_input">+ Income</a>')
    assert_includes(last_response.body, '<button type="submit">Save</button>')
  end

  def test_expenses_with_no_income
    get "/expenses"
    assert_equal(302, last_response.status)

    get last_response["Location"]
    assert_equal(200, last_response.status)
    assert_includes(last_response.body, '<p>Please provide some details about your income.</p>')
    assert_includes(last_response.body, '<form method="post" action="/income" id="save_income">')
  end

  def test_expenses
    post "/income", { income_name_1: "salary", income_amount_1: "700.00", income_occurance_1: "fortnightly" }
    assert_equal(302, last_response.status)

    get last_response["Location"]
    assert_equal(200, last_response.status)
    assert_includes(last_response.body, '<p>Income saved. You will be able to edit it later.</p>')
    assert_includes(last_response.body, '<form id="add_category">')
    assert_includes(last_response.body, '<form method="post" action="/expenses" id="save_expenses">')
    assert_includes(last_response.body, '<a herf="#" class="add_input">+ Expense</a>')
    assert_includes(last_response.body, '<button type="submit">Save</button>')
  end

  def test_summary_with_no_income
    get "/summary"
    assert_equal(302, last_response.status)

    get last_response["Location"]
    assert_equal(200, last_response.status)
    assert_includes(last_response.body, '<p>Please provide some details about your income.')
    assert_includes(last_response.body, '<form method="post" action="/income" id="save_income">')
    assert_includes(last_response.body, '<a herf="#" class="add_input">+ Income</a>')
    assert_includes(last_response.body, '<button type="submit">Save</button>')
  end

  def test_summary_with_no_expenses
    post "/income", { income_name_1: "salary", income_amount_1: "700.00", income_occurance_1: "fortnightly" }
    assert_equal(302, last_response.status)
    get last_response["Location"]
    assert_equal(200, last_response.status)
    assert_includes(last_response.body, '<p>Income saved. You will be able to edit it later.')

    get "/summary"
    assert_equal(302, last_response.status)

    get last_response["Location"]
    assert_equal(200, last_response.status)
    assert_includes(last_response.body, '<p>Please provide some details about your expenses.')
    assert_includes(last_response.body, '<form id="add_category">')
    assert_includes(last_response.body, '<form method="post" action="/expenses" id="save_expenses">')
    assert_includes(last_response.body, '<a herf="#" class="add_input">+ Expense</a>')
    assert_includes(last_response.body, '<button type="submit">Save</button>')
  end

  def test_summary
    post "/income", { income_name_1: "salary", income_amount_1: "700.00", income_occurance_1: "fortnightly" }
    post "/expenses", { category_name_1: "essentials", essentials_name_1: "rent", essentials_amount_1: "462.00", essentials_occurance_1: "monthly" }
  
    get "/summary"
    assert_equal(200, last_response.status)
    assert_includes(last_response.body, '<h1>Budget Planner</h1>')
    assert_includes(last_response.body, '<h2>Summary</h2>')
    assert_includes(last_response.body, '<h3>Income: £<span class="amount" data-monthly-amount="1520.83">1520.83</span></h3>')
    assert_includes(last_response.body, '<h3>Expenses: £<span class="amount" data-monthly-amount="462.0">462.0</span></h3>')
    assert_includes(last_response.body, '<h3>Spare Cash: £<span class="amount" data-monthly-amount="1058.83">1058.83</span></h3>')
  end
end
