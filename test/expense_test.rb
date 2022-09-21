require_relative 'test_helper'

require 'minitest/autorun'
require 'minitest/reporters'
MiniTest::Reporters.use!

require_relative '../lib/expense'

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
