require_relative 'money'

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
