require 'simplecov'
SimpleCov.start

require 'minitest/autorun'
require 'minitest/reporters'
MiniTest::Reporters.use!

require_relative '../lib/budget'

class BudgetTest < MiniTest::Test
  def setup
    @salary_income = Income.new('salary', 700, 'monthly')
    @passive_income = Income.new('passive', 100, 'fortnightly')

    @rent = Expense.new('rent', 462, 'monthly', 'essential')
    @groceries = Expense.new('groceries', 50, 'weekly', 'essential')
    @coffee = Expense.new('coffee', 6.40, 'daily', 'leisure')

    @budget = Budget.new
    @budget.add_income(@salary_income)
    @budget.add_income(@passive_income)
    @budget.add_expense(@rent)
    @budget.add_expense(@groceries)
    @budget.add_expense(@coffee)
  end

  def test_add_income
    sold_laptop = Income.new('sold laptop', 800, 'yearly')

    assert_equal(@budget.income, [@salary_income, @passive_income])
    @budget.add_income(sold_laptop)
    assert_equal(@budget.income, [@salary_income, @passive_income, sold_laptop])
  end

  def test_add_income_raise_error
    sold_laptop = { name: 'sold laptop', amount: 800, occurance: 'yearly'}
    assert_raises(TypeError) { @budget.add_income(sold_laptop)}
  end

  def test_add_expense
    transport = Expense.new('transport', 32, 'weekly', 'essential')

    assert_equal(@budget.expenses, [@rent, @groceries, @coffee])
    @budget.add_expense(transport)
    assert_equal(@budget.expenses, [@rent, @groceries, @coffee, transport])
  end

  def test_add_expense_raise_error
    transport = { name: 'transport', amount: 32, occurance: 'weekly', category: 'essential'}
    assert_raises(TypeError) { @budget.add_expense(transport) }
  end

  def test_remove_income
    assert_equal(@budget.income, [@salary_income, @passive_income])
    @budget.remove_income('passive')
    assert_equal(@budget.income, [@salary_income])
  end

  def test_remove_expense
    assert_equal(@budget.expenses, [@rent, @groceries, @coffee])
    @budget.remove_expense('coffee', 'leisure')
    assert_equal(@budget.expenses, [@rent, @groceries])
  end

  def test_income_by_name
    passive = @budget.income_by_name('passive')
    assert_equal(passive, @passive_income)
    assert_nil(@budget.income_by_name('royalty'))
  end

  def test_expenses_by_category
    essential = @budget.expenses_by_category('essential')
    business = @budget.expenses_by_category('business')

    assert_equal(essential, [@rent, @groceries])
    assert_empty(business)
  end

  def test_expense_by_category_and_name
    expense = @budget.expense_by_category_and_name('essential', 'groceries')
    assert_same(@groceries, expense)
  end

  def test_each_income
    result = []
    @budget.each_income { |income| result << income }
    assert_equal([@salary_income, @passive_income], result)
  end

  def test_each_expense
    result = []
    @budget.each_expense { |expense| result << expense }
    assert_equal([@rent, @groceries, @coffee], result)
  end
end

class ExpenseTest < MiniTest::Test
  def setup
    @daily_expense = Expense.new('coffee', 6.40, 'daily', 'leisure')
    @weekly_expense = Expense.new('travel', 30, 'weekly', 'essential')
    @fortnightly_expense = Expense.new('cinema', 20, 'fortnightly', 'leisure')
    @monthly_expense = Expense.new('subscription', 14.99, 'monthly', 'leisure')
    @quarterly_expense = Expense.new('theater', 100, 'quarterly', 'leisure')
    @six_monthly_expense = Expense.new('water', 1000, 'six_monthly', 'essential')
    @yearly_expense = Expense.new('council tax', 1200, 'yearly', 'essential')
  end

  def test_update_name
    assert_equal(@daily_expense.name, 'coffee')
    @daily_expense.update_name('tea')
    assert_equal(@daily_expense.name, 'tea')
  end

  def test_update_amount
    assert_equal(@daily_expense.amount, 6.40)
    @daily_expense.update_amount(5.20)
    assert_equal(@daily_expense.amount, 5.20)
  end

  def test_update_occurance
    assert_equal(@daily_expense.occurance, 'daily')
    @daily_expense.update_occurance('weekly')
    assert_equal(@daily_expense.occurance, 'weekly')
  end

  def test_update_category
    assert_equal(@daily_expense.category, 'leisure')
    @daily_expense.update_category('essential')
    assert_equal(@daily_expense.category, 'essential')
  end

  def test_to_daily
    daily_to_daily = @daily_expense.to_daily
    weekly_to_daily = @weekly_expense.to_daily
    fortnightly_to_daily = @fortnightly_expense.to_daily
    monthly_to_daily = @monthly_expense.to_daily
    quarterly_to_daily = @quarterly_expense.to_daily
    six_monthly_to_daily = @six_monthly_expense.to_daily
    yearly_to_daily = @yearly_expense.to_daily

    refute_same(@daily_expense, daily_to_daily)
    assert_equal(daily_to_daily.amount, 6.40)
    refute_same(@weekly_expense, weekly_to_daily)
    assert_equal(weekly_to_daily.amount, 4.285714285714286)
    refute_same(@fortnightly_expense, fortnightly_to_daily)
    assert_equal(fortnightly_to_daily.amount, 1.4285714285714286)
    refute_same(@monthly_expense, monthly_to_daily)
    assert_equal(monthly_to_daily.amount, 0.49282191780821916)
    refute_same(@quarterly_expense, quarterly_to_daily)
    assert_equal(quarterly_to_daily.amount, 1.095890410958904)
    refute_same(@six_monthly_expense, six_monthly_to_daily)
    assert_equal(six_monthly_to_daily.amount, 5.47945205479452)
    refute_same(@yearly_expense, yearly_to_daily)
    assert_equal(yearly_to_daily.amount, 3.287671232876712)
  end

  def test_to_weekly
    daily_to_weekly = @daily_expense.to_weekly
    weekly_to_weekly = @weekly_expense.to_weekly
    fortnightly_to_weekly = @fortnightly_expense.to_weekly
    monthly_to_weekly = @monthly_expense.to_weekly
    quarterly_to_weekly = @quarterly_expense.to_weekly
    six_monthly_to_weekly = @six_monthly_expense.to_weekly
    yearly_to_weekly = @yearly_expense.to_weekly

    refute_same(@daily_expense, daily_to_weekly)
    assert_equal(daily_to_weekly.amount, 44.80)
    refute_same(@weekly_expense, weekly_to_weekly)
    assert_equal(weekly_to_weekly.amount, 30)
    refute_same(@fortnightly_expense, fortnightly_to_weekly)
    assert_equal(fortnightly_to_weekly.amount, 10)
    refute_same(@monthly_expense, monthly_to_weekly)
    assert_equal(monthly_to_weekly.amount, 3.449753424657534)
    refute_same(@quarterly_expense, quarterly_to_weekly)
    assert_equal(quarterly_to_weekly.amount, 7.671232876712328)
    refute_same(@six_monthly_expense, six_monthly_to_weekly)
    assert_equal(six_monthly_to_weekly.amount, 38.35616438356164)
    refute_same(@yearly_expense, yearly_to_weekly)
    assert_equal(yearly_to_weekly.amount, 23.013698630136986)
  end

  def test_to_fortnightly
    daily_to_fortnightly = @daily_expense.to_fortnightly
    weekly_to_fortnightly = @weekly_expense.to_fortnightly
    fortnightly_to_fortnightly = @fortnightly_expense.to_fortnightly
    monthly_to_fortnightly = @monthly_expense.to_fortnightly
    quarterly_to_fortnightly = @quarterly_expense.to_fortnightly
    six_monthly_to_fortnightly = @six_monthly_expense.to_fortnightly
    yearly_to_fortnightly = @yearly_expense.to_fortnightly

    refute_same(@daily_expense, daily_to_fortnightly)
    assert_equal(daily_to_fortnightly.amount, 89.60000000000001)
    refute_same(@weekly_expense, weekly_to_fortnightly)
    assert_equal(weekly_to_fortnightly.amount, 60)
    refute_same(@fortnightly_expense, fortnightly_to_fortnightly)
    assert_equal(fortnightly_to_fortnightly.amount, 20)
    refute_same(@monthly_expense, monthly_to_fortnightly)
    assert_equal(monthly_to_fortnightly.amount, 6.899506849315068)
    refute_same(@quarterly_expense, quarterly_to_fortnightly)
    assert_equal(quarterly_to_fortnightly.amount, 15.342465753424657)
    refute_same(@six_monthly_expense, six_monthly_to_fortnightly)
    assert_equal(six_monthly_to_fortnightly.amount, 76.71232876712328)
    refute_same(@yearly_expense, yearly_to_fortnightly)
    assert_equal(yearly_to_fortnightly.amount, 46.02739726027397)
  end

  def test_to_monthly
    daily_to_monthly = @daily_expense.to_monthly
    weekly_to_monthly = @weekly_expense.to_monthly
    fortnightly_to_monthly = @fortnightly_expense.to_monthly
    monthly_to_monthly = @monthly_expense.to_monthly
    quarterly_to_monthly = @quarterly_expense.to_monthly
    six_monthly_to_monthly = @six_monthly_expense.to_monthly
    yearly_to_monthly = @yearly_expense.to_monthly

    refute_same(@daily_expense, daily_to_monthly)
    assert_equal(daily_to_monthly.amount, 194.66666666666666)
    refute_same(@weekly_expense, weekly_to_monthly)
    assert_equal(weekly_to_monthly.amount, 130.35714285714286)
    refute_same(@fortnightly_expense, fortnightly_to_monthly)
    assert_equal(fortnightly_to_monthly.amount, 43.452380952380956)
    refute_same(@monthly_expense, monthly_to_monthly)
    assert_equal(monthly_to_monthly.amount, 14.99)
    refute_same(@quarterly_expense, quarterly_to_monthly)
    assert_equal(quarterly_to_monthly.amount, 33.333333333333336)
    refute_same(@six_monthly_expense, six_monthly_to_monthly)
    assert_equal(six_monthly_to_monthly.amount, 166.66666666666666)
    refute_same(@yearly_expense, yearly_to_monthly)
    assert_equal(yearly_to_monthly.amount, 100)
  end

  def test_to_quarterly
    daily_to_quarterly = @daily_expense.to_quarterly
    weekly_to_quarterly = @weekly_expense.to_quarterly
    fortnightly_to_quarterly = @fortnightly_expense.to_quarterly
    monthly_to_quarterly = @monthly_expense.to_quarterly
    quarterly_to_quarterly = @quarterly_expense.to_quarterly
    six_monthly_to_quarterly = @six_monthly_expense.to_quarterly
    yearly_to_quarterly = @yearly_expense.to_quarterly

    refute_same(@daily_expense, daily_to_quarterly)
    assert_equal(daily_to_quarterly.amount, 582.40)
    refute_same(@weekly_expense, weekly_to_quarterly)
    assert_equal(weekly_to_quarterly.amount, 391.0714285714286)
    refute_same(@fortnightly_expense, fortnightly_to_quarterly)
    assert_equal(fortnightly_to_quarterly.amount, 130.35714285714286)
    refute_same(@monthly_expense, monthly_to_quarterly)
    assert_equal(monthly_to_quarterly.amount, 44.97)
    refute_same(@quarterly_expense, quarterly_to_quarterly)
    assert_equal(quarterly_to_quarterly.amount, 100)
    refute_same(@six_monthly_expense, six_monthly_to_quarterly)
    assert_equal(six_monthly_to_quarterly.amount, 500)
    refute_same(@yearly_expense, yearly_to_quarterly)
    assert_equal(yearly_to_quarterly.amount, 300)
  end

  def test_to_six_monthly
    daily_to_six_monthly = @daily_expense.to_six_monthly
    weekly_to_six_monthly = @weekly_expense.to_six_monthly
    fortnightly_to_six_monthly = @fortnightly_expense.to_six_monthly
    monthly_to_six_monthly = @monthly_expense.to_six_monthly
    quarterly_to_six_monthly = @quarterly_expense.to_six_monthly
    six_monthly_to_six_monthly = @six_monthly_expense.to_six_monthly
    yearly_to_six_monthly = @yearly_expense.to_six_monthly

    refute_same(@daily_expense, daily_to_six_monthly)
    assert_equal(daily_to_six_monthly.amount, 1168)
    refute_same(@weekly_expense, weekly_to_six_monthly)
    assert_equal(weekly_to_six_monthly.amount, 782.1428571428572)
    refute_same(@fortnightly_expense, fortnightly_to_six_monthly)
    assert_equal(fortnightly_to_six_monthly.amount, 260.7142857142857)
    refute_same(@monthly_expense, monthly_to_six_monthly)
    assert_equal(monthly_to_six_monthly.amount, 89.94)
    refute_same(@quarterly_expense, quarterly_to_six_monthly)
    assert_equal(quarterly_to_six_monthly.amount, 200)
    refute_same(@six_monthly_expense, six_monthly_to_six_monthly)
    assert_equal(six_monthly_to_six_monthly.amount, 1000)
    refute_same(@yearly_expense, yearly_to_six_monthly)
    assert_equal(yearly_to_six_monthly.amount, 600)
  end

  def test_to_yearly
    daily_to_yearly = @daily_expense.to_yearly
    weekly_to_yearly = @weekly_expense.to_yearly
    fortnightly_to_yearly = @fortnightly_expense.to_yearly
    monthly_to_yearly = @monthly_expense.to_yearly
    quarterly_to_yearly = @quarterly_expense.to_yearly
    six_monthly_to_yearly = @six_monthly_expense.to_yearly
    yearly_to_yearly = @yearly_expense.to_yearly

    refute_same(@daily_expense, daily_to_yearly)
    assert_equal(daily_to_yearly.amount, 2336)
    refute_same(@weekly_expense, weekly_to_yearly)
    assert_equal(weekly_to_yearly.amount, 1564.2857142857144)
    refute_same(@fortnightly_expense, fortnightly_to_yearly)
    assert_equal(fortnightly_to_yearly.amount, 521.4285714285714)
    refute_same(@monthly_expense, monthly_to_yearly)
    assert_equal(monthly_to_yearly.amount, 179.88)
    refute_same(@quarterly_expense, quarterly_to_yearly)
    assert_equal(quarterly_to_yearly.amount, 400)
    refute_same(@six_monthly_expense, six_monthly_to_yearly)
    assert_equal(six_monthly_to_yearly.amount, 2000)
    refute_same(@yearly_expense, yearly_to_yearly)
    assert_equal(yearly_to_yearly.amount, 1200)
  end
end

class IncomeTest < MiniTest::Test
  def setup
    @daily_income = Income.new('royalty', 12, 'daily')
    @weekly_income = Income.new('sales', 199, 'weekly')
    @fortnightly_income = Income.new('salary 1', 60, 'fortnightly')
    @monthly_income = Income.new('salary 2', 1432, 'monthly')
    @quarterly_income = Income.new('rent', 3000, 'quarterly')
    @six_monthly_income = Income.new('loan', 2040, 'six_monthly')
    @yearly_income = Income.new('services', 1565, 'yearly')
  end

  def test_update_name
    assert_equal(@monthly_income.name, 'salary 2')
    @monthly_income.update_name('royalty')
    assert_equal(@monthly_income.name, 'royalty')
  end

  def test_update_amount
    assert_equal(@monthly_income.amount, 1432)
    @monthly_income.update_amount(500)
    assert_equal(@monthly_income.amount, 500)
  end

  def test_update_occurance
    assert_equal(@monthly_income.occurance, 'monthly')
    @monthly_income.update_occurance('quarterly')
    assert_equal(@monthly_income.occurance, 'quarterly')
  end

  def test_to_daily
    daily_to_daily = @daily_income.to_daily
    weekly_to_daily = @weekly_income.to_daily
    fortnightly_to_daily = @fortnightly_income.to_daily
    monthly_to_daily = @monthly_income.to_daily
    quarterly_to_daily = @quarterly_income.to_daily
    six_monthly_to_daily = @six_monthly_income.to_daily
    yearly_to_daily = @yearly_income.to_daily

    refute_same(@daily_income, daily_to_daily)
    assert_equal(daily_to_daily.amount, 12)
    refute_same(@weekly_income, weekly_to_daily)
    assert_equal(weekly_to_daily.amount, 28.428571428571427)
    refute_same(@fortnightly_income, fortnightly_to_daily)
    assert_equal(fortnightly_to_daily.amount, 4.285714285714286)
    refute_same(@monthly_income, monthly_to_daily)
    assert_equal(monthly_to_daily.amount, 47.07945205479452)
    refute_same(@quarterly_income, quarterly_to_daily)
    assert_equal(quarterly_to_daily.amount, 32.87671232876713)
    refute_same(@six_monthly_income, six_monthly_to_daily)
    assert_equal(six_monthly_to_daily.amount, 11.178082191780822)
    refute_same(@yearly_income, yearly_to_daily)
    assert_equal(yearly_to_daily.amount, 4.287671232876712)
  end

  def test_to_weekly
    daily_to_weekly = @daily_income.to_weekly
    weekly_to_weekly = @weekly_income.to_weekly
    fortnightly_to_weekly = @fortnightly_income.to_weekly
    monthly_to_weekly = @monthly_income.to_weekly
    quarterly_to_weekly = @quarterly_income.to_weekly
    six_monthly_to_weekly = @six_monthly_income.to_weekly
    yearly_to_weekly = @yearly_income.to_weekly

    refute_same(@daily_income, daily_to_weekly)
    assert_equal(daily_to_weekly.amount, 84)
    refute_same(@weekly_income, weekly_to_weekly)
    assert_equal(weekly_to_weekly.amount, 199)
    refute_same(@fortnightly_income, fortnightly_to_weekly)
    assert_equal(fortnightly_to_weekly.amount, 30)
    refute_same(@monthly_income, monthly_to_weekly)
    assert_equal(monthly_to_weekly.amount, 329.5561643835616)
    refute_same(@quarterly_income, quarterly_to_weekly)
    assert_equal(quarterly_to_weekly.amount, 230.13698630136986)
    refute_same(@six_monthly_income, six_monthly_to_weekly)
    assert_equal(six_monthly_to_weekly.amount, 78.24657534246575)
    refute_same(@yearly_income, yearly_to_weekly)
    assert_equal(yearly_to_weekly.amount, 30.013698630136986)
  end

  def test_to_fortnightly
    daily_to_fortnightly = @daily_income.to_fortnightly
    weekly_to_fortnightly = @weekly_income.to_fortnightly
    fortnightly_to_fortnightly = @fortnightly_income.to_fortnightly
    monthly_to_fortnightly = @monthly_income.to_fortnightly
    quarterly_to_fortnightly = @quarterly_income.to_fortnightly
    six_monthly_to_fortnightly = @six_monthly_income.to_fortnightly
    yearly_to_fortnightly = @yearly_income.to_fortnightly

    refute_same(@daily_income, daily_to_fortnightly)
    assert_equal(daily_to_fortnightly.amount, 168)
    refute_same(@weekly_income, weekly_to_fortnightly)
    assert_equal(weekly_to_fortnightly.amount, 398)
    refute_same(@fortnightly_income, fortnightly_to_fortnightly)
    assert_equal(fortnightly_to_fortnightly.amount, 60)
    refute_same(@monthly_income, monthly_to_fortnightly)
    assert_equal(monthly_to_fortnightly.amount, 659.1123287671232)
    refute_same(@quarterly_income, quarterly_to_fortnightly)
    assert_equal(quarterly_to_fortnightly.amount, 460.2739726027397)
    refute_same(@six_monthly_income, six_monthly_to_fortnightly)
    assert_equal(six_monthly_to_fortnightly.amount, 156.4931506849315)
    refute_same(@yearly_income, yearly_to_fortnightly)
    assert_equal(yearly_to_fortnightly.amount, 60.02739726027397)
  end

  def test_to_monthly
    daily_to_monthly = @daily_income.to_monthly
    weekly_to_monthly = @weekly_income.to_monthly
    fortnightly_to_monthly = @fortnightly_income.to_monthly
    monthly_to_monthly = @monthly_income.to_monthly
    quarterly_to_monthly = @quarterly_income.to_monthly
    six_monthly_to_monthly = @six_monthly_income.to_monthly
    yearly_to_monthly = @yearly_income.to_monthly

    refute_same(@daily_income, daily_to_monthly)
    assert_equal(daily_to_monthly.amount, 365)
    refute_same(@weekly_income, weekly_to_monthly)
    assert_equal(weekly_to_monthly.amount, 864.7023809523811)
    refute_same(@fortnightly_income, fortnightly_to_monthly)
    assert_equal(fortnightly_to_monthly.amount, 130.35714285714286)
    refute_same(@monthly_income, monthly_to_monthly)
    assert_equal(monthly_to_monthly.amount, 1432)
    refute_same(@quarterly_income, quarterly_to_monthly)
    assert_equal(quarterly_to_monthly.amount, 1000)
    refute_same(@six_monthly_income, six_monthly_to_monthly)
    assert_equal(six_monthly_to_monthly.amount, 340)
    refute_same(@yearly_income, yearly_to_monthly)
    assert_equal(yearly_to_monthly.amount, 130.41666666666666)
  end

  def test_to_quarterly
    daily_to_quarterly = @daily_income.to_quarterly
    weekly_to_quarterly = @weekly_income.to_quarterly
    fortnightly_to_quarterly = @fortnightly_income.to_quarterly
    monthly_to_quarterly = @monthly_income.to_quarterly
    quarterly_to_quarterly = @quarterly_income.to_quarterly
    six_monthly_to_quarterly = @six_monthly_income.to_quarterly
    yearly_to_quarterly = @yearly_income.to_quarterly

    refute_same(@daily_income, daily_to_quarterly)
    assert_equal(daily_to_quarterly.amount, 1092)
    refute_same(@weekly_income, weekly_to_quarterly)
    assert_equal(weekly_to_quarterly.amount, 2594.107142857143)
    refute_same(@fortnightly_income, fortnightly_to_quarterly)
    assert_equal(fortnightly_to_quarterly.amount, 391.0714285714286)
    refute_same(@monthly_income, monthly_to_quarterly)
    assert_equal(monthly_to_quarterly.amount, 4296)
    refute_same(@quarterly_income, quarterly_to_quarterly)
    assert_equal(quarterly_to_quarterly.amount, 3000)
    refute_same(@six_monthly_income, six_monthly_to_quarterly)
    assert_equal(six_monthly_to_quarterly.amount, 1020)
    refute_same(@yearly_income, yearly_to_quarterly)
    assert_equal(yearly_to_quarterly.amount, 391.25)
  end

  def test_to_six_monthly
    daily_to_six_monthly = @daily_income.to_six_monthly
    weekly_to_six_monthly = @weekly_income.to_six_monthly
    fortnightly_to_six_monthly = @fortnightly_income.to_six_monthly
    monthly_to_six_monthly = @monthly_income.to_six_monthly
    quarterly_to_six_monthly = @quarterly_income.to_six_monthly
    six_monthly_to_six_monthly = @six_monthly_income.to_six_monthly
    yearly_to_six_monthly = @yearly_income.to_six_monthly

    refute_same(@daily_income, daily_to_six_monthly)
    assert_equal(daily_to_six_monthly.amount, 2190)
    refute_same(@weekly_income, weekly_to_six_monthly)
    assert_equal(weekly_to_six_monthly.amount, 5188.214285714286)
    refute_same(@fortnightly_income, fortnightly_to_six_monthly)
    assert_equal(fortnightly_to_six_monthly.amount, 782.1428571428572)
    refute_same(@monthly_income, monthly_to_six_monthly)
    assert_equal(monthly_to_six_monthly.amount, 8592)
    refute_same(@quarterly_income, quarterly_to_six_monthly)
    assert_equal(quarterly_to_six_monthly.amount, 6000)
    refute_same(@six_monthly_income, six_monthly_to_six_monthly)
    assert_equal(six_monthly_to_six_monthly.amount, 2040)
    refute_same(@yearly_income, yearly_to_six_monthly)
    assert_equal(yearly_to_six_monthly.amount, 782.5)
  end

  def test_to_yearly
    daily_to_yearly = @daily_income.to_yearly
    weekly_to_yearly = @weekly_income.to_yearly
    fortnightly_to_yearly = @fortnightly_income.to_yearly
    monthly_to_yearly = @monthly_income.to_yearly
    quarterly_to_yearly = @quarterly_income.to_yearly
    six_monthly_to_yearly = @six_monthly_income.to_yearly
    yearly_to_yearly = @yearly_income.to_yearly

    refute_same(@daily_income, daily_to_yearly)
    assert_equal(daily_to_yearly.amount, 4380)
    refute_same(@weekly_income, weekly_to_yearly)
    assert_equal(weekly_to_yearly.amount, 10376.428571428572)
    refute_same(@fortnightly_income, fortnightly_to_yearly)
    assert_equal(fortnightly_to_yearly.amount, 1564.2857142857144)
    refute_same(@monthly_income, monthly_to_yearly)
    assert_equal(monthly_to_yearly.amount, 17184)
    refute_same(@quarterly_income, quarterly_to_yearly)
    assert_equal(quarterly_to_yearly.amount, 12000)
    refute_same(@six_monthly_income, six_monthly_to_yearly)
    assert_equal(six_monthly_to_yearly.amount, 4080)
    refute_same(@yearly_income, yearly_to_yearly)
    assert_equal(yearly_to_yearly.amount, 1565)
  end
end
