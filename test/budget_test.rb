require_relative 'test_helper'
require_relative '../lib/budget'
require_relative '../lib/income'
require_relative '../lib/expense'

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
