require './init'

class TestScenarios < TestClass

  def setup
    @db = LocalDB.new
  end

  def test_six_scenarios
    # 1.) Look up the customer named Morton Dryden, and get a list of all of their orders.
    orders = get_client_orders('Morton Dryden')
    assert_equal(220, orders[:summary])

    # 2.) Look up all the orders that have a total greater than 100.
    thresholds = get_order_threshold(100)
    assert_equal(5, thresholds.length)

    # 3.) An order from Alice Bundy for a total of 255 went missing and you need to put it in manually.
    customer = 'Alice Bundy'
    account = get_clients(customer).first
    assert_match(customer.split(' ').first, account[:first_name])
    assert_match(customer.split(' ').last, account[:last_name])
    orders = get_client_orders(account[:id])
    orders[:orders].each do |order|
      refute_equal(255, order[:units])
    end
    orders = add_new_orders(account[:id], 255)
    assert_equal(255, orders[:orders].last[:units])

    # 4.) Melissa Doran recently married and changed her last name to Sanchez. Update her customer record to reflect the change.
    customer = 'Melissa Doran'
    account = get_clients(customer).first
    assert_match(customer.split(' ').first, account[:first_name])
    assert_match(customer.split(' ').last, account[:last_name])
    customer_update = 'Melissa Sanchez'
    update = update_client_records(customer, customer_update)
    assert_match(customer_update.split(' ').first, update[:first_name])
    assert_match(customer_update.split(' ').last, update[:last_name])

    # 5.) Management went crazy and wants you to find all the customers that do not have an order and delete them.
    inactive_clients = clear_all_clients_with_no_orders
    assert_equal(2, inactive_clients.length)
    assert_includes(inactive_clients, 3)
    assert_includes(inactive_clients, 6)
    active_accounts = get_clients
    active_accounts.each do |active|
      refute_includes(inactive_clients, active[:id])
    end

    # 6.) Look up all the customers that have made more than one order.
    expected_client_ids = [1, 5]
    repeat_customers = get_repeat_customers
    repeat_customers.each do |vip_clients|
      assert_includes(expected_client_ids, vip_clients[:id])
    end
  end
end
