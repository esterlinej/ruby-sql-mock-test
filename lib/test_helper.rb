module TestHelper
  def add_new_client(client)
    return unless client && client.is_a?(String)

    confirmation = nil
    full_name = client.split(' ')
    unless @db.clients.where(:first_name => full_name[0], :last_name => full_name[1])
      @db.clients.insert(:first_name => full_name[0], :last_name => full_name[1])
      confirmation = @db.clients.where(:first_name => full_name[0], :last_name => full_name[1])
    end

    confirmation
  end

  def update_client_records(original=nil, update=nil)
    return unless original && original.is_a?(String) && update && update.is_a?(String)

    full_name = original.split(' ')
    client = @db.clients.where(:first_name => full_name[0], :last_name => full_name[1])

    if client
      new_name = update.split(' ')
      if client[:first_name] != new_name[0] && client[:last_name] != new_name[1]
        @db.clients.where(:first_name => full_name[0], :last_name => full_name[1])
            .update(:first_name => new_name[0], :last_name => new_name[1])
      elsif client[:first_name] != new_name[0] && client[:last_name] == new_name[1]
        @db.clients.where(:first_name => full_name[0], :last_name => full_name[1])
            .update(:first_name => new_name[0])
      elsif client[:first_name] == new_name[0] && client[:last_name] != new_name[1]
        @db.clients.where(:first_name => full_name[0], :last_name => full_name[1])
            .update(:last_name => new_name[1])
      end

      confirmation = nil
      all_clients = @db.clients.select_all
      all_clients.each do |client|
        if client[:first_name] == new_name[0] && client[:last_name] == new_name[1]
          confirmation = client
          break
        end
      end

      confirmation
    end
  end

  def delete_client_records(client=nil)
    return unless client

    client = get_clients(client)
    @db.clients.where(:id => client.first[:id]).delete
  end

  def add_new_orders(clid, order)
    return unless (clid && clid.is_a?(Integer)) && (order && order.is_a?(Integer))

    @db.orders.insert(:client_id => clid, :units => order)

    get_client_orders(clid)
  end

  def get_clients(clients=nil)
    clients = Array(clients) unless clients.is_a?(Array)

    requested_clients = []
    clients.each do |client|
      if client.is_a?(String)
        full_name = client.split(' ')
        client_check = @db.clients.first(:first_name => full_name[0], :last_name => full_name[1])
        if client_check && client_check[:first_name] == full_name[0] && client_check[:last_name] == full_name[1]
          requested_clients << client_check
        end
      elsif client.is_a?(Integer)
        client_check = @db.clients.first(:id => client)
        if client_check && client_check[:id] == client
          requested_clients << client_check
        end
      end
    end

    if requested_clients.empty?
      all_clients = @db.clients.select_all
      all_clients.each do |account|
        requested_clients << account
      end
    end

    requested_clients
  end

  def get_client_orders(client=nil)
    return unless client

    clients_orders = []
    client = get_clients([client]).first
    all_orders = @db.orders.select_all
    all_orders.each do |order|
      if order[:client_id] == client[:id]
        clients_orders << order
      end
    end

    order_count = 0
    clients_orders.each do |order|
      if order[:units]
        order_count += order[:units]
      end
    end

    {
        orders: clients_orders,
        summary: order_count
    }
  end

  def get_repeat_customers
    all_clients = @db.clients.select_all
    clients = []
    all_clients.each do |client|
      clients << client if client
    end
    client_ids = clients.map { |client| client[:id] }

    all_orders = @db.orders.select_all
    orders = []
    all_orders.each do |order|
      orders << order if order
    end
    orders_by_client = orders.map { |order| order[:client_id] }

    repeat_customer_ids = []
    client_ids.each do |clid|
      total_orders = orders_by_client.count(clid)
      repeat_customer_ids << clid if total_orders > 1
    end

    get_clients(repeat_customer_ids)
  end

  def get_order_threshold(threshold=1)
    threshold_orders = []
    all_orders = @db.orders.select_all
    all_orders.each do |order|
      if order[:units] >= threshold
        threshold_orders << order
      end
    end

    threshold_orders
  end

  def clear_all_clients_with_no_orders
    active_client_ids = []
    inactive_client_ids = []

    @db.orders.each do |order|
      active_client_ids << order[:client_id]
    end
    active_client_ids.uniq!

    @db.clients.each do |client|
      unless active_client_ids.include?(client[:id])
        inactive_client_ids << client[:id]
      end
    end

    inactive_client_ids.each do |id|
      delete_client_records(id)
    end

    inactive_client_ids
  end
end
