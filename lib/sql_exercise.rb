require "database_connection"

class SqlExercise

  attr_reader :database_connection

  def initialize
    @database_connection = DatabaseConnection.new
  end

  def all_customers
    database_connection.sql("SELECT * from customers")
  end

  def limit_customers(num)
    database_connection.sql("SELECT * from customers LIMIT #{params(num)}")
  end

  def order_customers(order_by)
    database_connection.sql("SELECT * from customers order by name #{params(order_by)}")
  end

  def id_and_name_for_customers
    database_connection.sql("select id, name from customers")
  end

  def all_items
    database_connection.sql("select * from items")
  end

  def find_item_by_name(name)
    database_connection.sql(
      "select * from items where name = '#{params(name)}'"
      ).first
  end

  def count_customers
    database_connection.sql(
      "select count(*) from customers"
      )[0]["count"].to_i
  end

  def sum_order_amounts
    database_connection.sql(
      "select sum(amount) from orders"
      )[0]["sum"].to_f
  end

  def minimum_order_amount_for_customers
    database_connection.sql(
      "select min(amount), customer_id from orders
      group by customer_id")
  end

  def customer_order_totals
    database_connection.sql(
      "select customers.name, customer_id, sum(amount) from orders
      inner join customers on customers.id = orders.customer_id
      group by customer_id, customers.name"
      )
  end

  def items_ordered_by_user(id)
    items = database_connection.sql(
      "select items.name from items
      inner join orderitems on items.id = orderitems.item_id
      inner join orders on orders.id = orderitems.order_id
      where orders.customer_id = #{id}"
      )

    items.collect {|item| item["name"]}
  end

  def customers_that_bought_item(item)
    database_connection.sql(
      "select customers.name as customer_name, customers.id from items
      inner join orderitems on items.id = orderitems.item_id
      inner join orders on orders.id = orderitems.order_id
      inner join customers on customers.id = orders.customer_id
      where items.name = '#{item}'"
      ).uniq
  end

  def customers_that_bought_item_in_state(item, state)
    database_connection.sql(
      "select customers.* from items
      inner join orderitems on items.id = orderitems.item_id
      inner join orders on orders.id = orderitems.order_id
      inner join customers on customers.id = orders.customer_id
      where items.name = '#{item}' and customers.state = '#{state}'"
      ).first
  end

  private

  def params(input)
    string = input.to_s.downcase.split("; drop").first
    if string.to_i > 0
      string.to_i
    else
      string.delete "\""
      string.delete "'"
    end
  end
end
