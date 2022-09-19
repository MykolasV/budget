require 'bundler/setup'
require 'date'

class Money
  DAYS_IN_YEAR   = Date.today.leap? ? 366 : 365
  WEEKS_IN_YEAR  = DAYS_IN_YEAR / 7.0

  attr_reader :name, :amount, :occurance

  def initialize(name, amount, occurance)
    @name = name
    @amount = amount.to_f
    @occurance = occurance
  end

  def update_name(new_name)
    self.name = new_name
  end

  def update_amount(new_amount)
    self.amount = new_amount
  end

  def update_occurance(new_occurance)
    self.occurance = new_occurance
  end

  def to_daily
    new_amount = nil

    if occurance == 'weekly'
      new_amount = amount / 7
    elsif occurance == 'fortnightly'
      new_amount = amount / 14
    elsif occurance == 'monthly'
      new_amount = (amount * 12) / DAYS_IN_YEAR
    elsif occurance == 'quarterly'
      new_amount = (amount * 4) / DAYS_IN_YEAR
    elsif occurance == 'six_monthly'
      new_amount = (amount * 2) / DAYS_IN_YEAR
    elsif occurance == 'yearly'
      new_amount = amount / DAYS_IN_YEAR
    else
      new_amount = amount
    end

    if self.instance_of?(Expense)
      Expense.new(name, new_amount, 'daily', category)
    else
      self.class.new(name, new_amount, 'daily')
    end
  end

  def to_weekly
    new_amount = nil

    if occurance == 'daily'
      new_amount = (amount * DAYS_IN_YEAR) / WEEKS_IN_YEAR
    elsif occurance == 'fortnightly'
      new_amount = amount / 2
    elsif occurance == 'monthly'
      new_amount = (amount * 12) / WEEKS_IN_YEAR
    elsif occurance == 'quarterly'
      new_amount = (amount * 4) / WEEKS_IN_YEAR
    elsif occurance == 'six_monthly'
      new_amount = (amount * 2) / WEEKS_IN_YEAR
    elsif occurance == 'yearly'
      new_amount = amount / WEEKS_IN_YEAR
    else
      new_amount = amount
    end

    if self.instance_of?(Expense)
      Expense.new(name, new_amount, 'weekly', category)
    else
      self.class.new(name, new_amount, 'weekly')
    end
  end

  def to_fortnightly
    new_amount = nil

    if occurance == 'daily'
      new_amount = amount * 14
    elsif occurance == 'weekly'
      new_amount = amount * 2
    elsif occurance == 'monthly'
      new_amount = ((amount * 12) / WEEKS_IN_YEAR) * 2
    elsif occurance == 'quarterly'
      new_amount = ((amount * 4) / WEEKS_IN_YEAR) * 2
    elsif occurance == 'six_monthly'
      new_amount = ((amount * 2) / WEEKS_IN_YEAR) * 2
    elsif occurance == 'yearly'
      new_amount = (amount / WEEKS_IN_YEAR) * 2
    else
      new_amount = amount
    end

    if self.instance_of?(Expense)
      Expense.new(name, new_amount, 'fortnightly', category)
    else
      self.class.new(name, new_amount, 'fortnightly')
    end
  end

  def to_monthly
    new_amount = nil

    if occurance == 'daily'
      new_amount = (amount * DAYS_IN_YEAR) / 12
    elsif occurance == 'weekly'
      new_amount = (amount * WEEKS_IN_YEAR) / 12
    elsif occurance == 'fortnightly'
      new_amount = ((amount / 2) * WEEKS_IN_YEAR) / 12
    elsif occurance == 'quarterly'
      new_amount = (amount * 4) / 12
    elsif occurance == 'six_monthly'
      new_amount = (amount * 2) / 12
    elsif occurance == 'yearly'
      new_amount = amount / 12
    else
      new_amount = amount
    end

    if self.instance_of?(Expense)
      Expense.new(name, new_amount, 'monthly', category)
    else
      self.class.new(name, new_amount, 'monthly')
    end
  end

  def to_quarterly
    new_amount = nil

    if occurance == 'daily'
      new_amount = amount * (DAYS_IN_YEAR / 4)
    elsif occurance == 'weekly'
      new_amount = amount * (WEEKS_IN_YEAR / 4)
    elsif occurance == 'fortnightly'
      new_amount = (amount / 2) * (WEEKS_IN_YEAR / 4)
    elsif occurance == 'monthly'
      new_amount = amount * 3
    elsif occurance == 'six_monthly'
      new_amount = amount / 2
    elsif occurance == 'yearly'
      new_amount = amount / 4
    else
      new_amount = amount
    end

    if self.instance_of?(Expense)
      Expense.new(name, new_amount, 'quarterly', category)
    else
      self.class.new(name, new_amount, 'quarterly')
    end
  end

  def to_six_monthly
    new_amount = nil

    if occurance == 'daily'
      new_amount = (amount * DAYS_IN_YEAR) / 2
    elsif occurance == 'weekly'
      new_amount = (amount * WEEKS_IN_YEAR) / 2
    elsif occurance == 'fortnightly'
      new_amount = ((amount / 2) * WEEKS_IN_YEAR) / 2
    elsif occurance == 'monthly'
      new_amount = amount * 6
    elsif occurance == 'quarterly'
      new_amount = amount * 2
    elsif occurance == 'yearly'
      new_amount = amount / 2
    else
      new_amount = amount
    end

    if self.instance_of?(Expense)
      Expense.new(name, new_amount, 'six_monthly', category)
    else
      self.class.new(name, new_amount, 'six_monthly')
    end
  end

  def to_yearly
    new_amount = nil

    if occurance == 'daily'
      new_amount = amount * DAYS_IN_YEAR
    elsif occurance == 'weekly'
      new_amount = amount * WEEKS_IN_YEAR
    elsif occurance == 'fortnightly'
      new_amount = (amount / 2) * WEEKS_IN_YEAR
    elsif occurance == 'monthly'
      new_amount = amount * 12
    elsif occurance == 'quarterly'
      new_amount = amount * 4
    elsif occurance == 'six_monthly'
      new_amount = amount * 2
    else
      new_amount = amount
    end

    if self.instance_of?(Expense)
      Expense.new(name, new_amount, 'yearly', category)
    else
      self.class.new(name, new_amount, 'yearly')
    end
  end

  private

  attr_writer :name, :amount, :occurance
end

class Income < Money
end

class Expense < Money
  attr_reader :category

  def initialize(name, amount, occurance, category)
    super(name, amount, occurance)
    @category = category
  end

  def update_category(new_category)
    self.category = new_category
  end

  private

  attr_writer :category
end

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

  def remove_expense(category, name, amount, occurance)
    @expenses.delete_if do |expense|
      expense.category == category && expense.name == name &&
      expense.amount == amount && expense.occurance == occurance
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
