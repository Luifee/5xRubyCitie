class Cart

  attr_reader :items

  def initialize
    @items = []
  end

  def add_item(product_id, quantity = 1)
    found = @items.find { |item| item.product_id == product_id }

    if found
      found.increment!
    else
      @items << CartItem.new(product_id, quantity)
    end
  end

  def empty?
    @items.empty?
  end

end
