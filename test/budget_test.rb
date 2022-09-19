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
    @expense = Expense.new('coffee', 6.40, 'daily', 'leisure')
  end

  def test_update_name
    assert_equal(@expense.name, 'coffee')
    @expense.update_name('tea')
    assert_equal(@expense.name, 'tea')
  end

  def test_update_amount
    assert_equal(@expense.amount, 6.40)
    @expense.update_amount(5.20)
    assert_equal(@expense.amount, 5.20)
  end

  def test_update_occurance
    assert_equal(@expense.occurance, 'daily')
    @expense.update_occurance('weekly')
    assert_equal(@expense.occurance, 'weekly')
  end

  def test_update_category
    assert_equal(@expense.category, 'leisure')
    @expense.update_category('essential')
    assert_equal(@expense.category, 'essential')
  end

  def test_to_daily
    daily = @expense.to_daily
    refute_same(@expense, daily)
    assert_equal(daily.amount, 6.40)
  end

  def test_to_weekly
    weekly = @expense.to_weekly
    refute_same(@expense, weekly)
    assert_equal(weekly.amount, 44.80)
  end

  def test_to_fortnightly
    fortnightly = @expense.to_fortnightly
    refute_same(@expense, fortnightly)
    assert_equal(fortnightly.amount, 89.60000000000001)
  end

  def test_to_monthly
    monthly = @expense.to_monthly
    refute_same(@expense, monthly)
    assert_equal(monthly.amount, 194.66666666666666)
  end

  def test_to_quarterly
    quarterly = @expense.to_quarterly
    refute_same(@expense, quarterly)
    assert_equal(quarterly.amount, 582.40)
  end

  def test_to_six_monthly
    six_monthly = @expense.to_six_monthly
    refute_same(@expense, six_monthly)
    assert_equal(six_monthly.amount, 1168)
  end

  def test_to_yearly
    yearly = @expense.to_yearly
    refute_same(@expense, yearly)
    assert_equal(yearly.amount, 2336)
  end
end

class IncomeTest < MiniTest::Test
  def setup
    @income = Income.new('salary', 700, 'monthly')
  end

  def test_update_name
    assert_equal(@income.name, 'salary')
    @income.update_name('royalty')
    assert_equal(@income.name, 'royalty')
  end

  def test_update_amount
    assert_equal(@income.amount, 700)
    @income.update_amount(500)
    assert_equal(@income.amount, 500)
  end

  def test_update_occurance
    assert_equal(@income.occurance, 'monthly')
    @income.update_occurance('quarterly')
    assert_equal(@income.occurance, 'quarterly')
  end

  def test_to_daily
    daily = @income.to_daily
    refute_same(@income, daily)
    assert_equal(daily.amount, 23.013698630136986)
  end

  def test_to_weekly
    weekly = @income.to_weekly
    refute_same(@income, weekly)
    assert_equal(weekly.amount, 161.0958904109589)
  end

  def test_to_fortnightly
    fortnightly = @income.to_fortnightly
    refute_same(@income, fortnightly)
    assert_equal(fortnightly.amount, 322.1917808219178)
  end

  def test_to_monthly
    monthly = @income.to_monthly
    refute_same(@income, monthly)
    assert_equal(monthly.amount, 700)
  end

  def test_to_quarterly
    quarterly = @income.to_quarterly
    refute_same(@income, quarterly)
    assert_equal(quarterly.amount, 2100)
  end

  def test_to_six_monthly
    six_monthly = @income.to_six_monthly
    refute_same(@income, six_monthly)
    assert_equal(six_monthly.amount, 4200)
  end

  def test_to_yearly
    yearly = @income.to_yearly
    refute_same(@income, yearly)
    assert_equal(yearly.amount, 8400)
  end
end
