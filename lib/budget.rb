require 'bundler/setup'

class Budget
  attr_reader :income, :expenses

  def initialize
    @income = []
    @expenses = []
  end

  def add_income(income)
    raise TypeError, 'can only add Income objects' unless income.instance_of?(Income)

    @income << income
  end

  def remove_income(name)
    @income.delete_if { |income| income.name == name }
  end

  def add_expense(expense)
    raise TypeError, 'can only add Expense objects' unless expense.instance_of?(Expense)

    @expenses << expense
  end

  def remove_expense(name, category)
    name = name.downcase
    category = category.downcase

    @expenses.delete_if do |expense|
      expense.category.downcase == category && expense.name.downcase == name
    end
  end

  def income_by_name(name)
    name = name.downcase
    @income.select { |income| income.name.downcase == name }.first
  end

  def expenses_by_category(category)
    category = category.downcase
    @expenses.select { |expense| expense.category.downcase == category }
  end

  def expense_by_category_and_name(category, name)
    category = category.downcase
    name = name.downcase

    selected = @expenses.select do |expense|
      expense.category.downcase == category && expense.name.downcase == name
    end

    selected.first
  end

  def each_income
    @income.each do |income|
      yield(income)
    end
  end

  def each_expense
    @expenses.each do |expense|
      yield(expense)
    end
  end
end
