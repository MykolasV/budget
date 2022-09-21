require_relative 'test_helper'

require 'minitest/autorun'
require 'minitest/reporters'
MiniTest::Reporters.use!

require_relative '../lib/income'
require_relative '../lib/expense'

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
