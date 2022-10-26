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
end
