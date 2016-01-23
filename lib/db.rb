class LocalDB
  PRIMARY_CLIENTS = [
      'Bob Wilson',
      'Terry Brand',
      'Melissa Doran',
      'Morton Dryden',
      'Alice Bundy',
      'Mary Womack',
      'Phillip Kwon'
  ]

  CURRENT_ORDERS = [
      {
          client_id: 1,
          units: 100
      },
      {
          client_id: 4,
          units: 220
      },
      {
          client_id: 7,
          units: 700
      },
      {
          client_id: 5,
          units: 165
      },
      {
          client_id: 5,
          units: 75
      },
      {
          client_id: 1,
          units: 250
      },
      {
          client_id: 2,
          units: 25
      },
  ]

  attr_accessor :current_client_id, :current_order_id, :clients, :orders

  def initialize
    @db = Sequel.sqlite

    @db.create_table(:Clients) do
      primary_key :id
      String :first_name
      String :last_name
    end

    @db.create_table(:Orders) do
      primary_key :id
      Integer :client_id
      Integer :units
    end

    @current_client_id = 1
    @current_order_id = 1

    @clients = @db[:Clients]
    @orders = @db[:Orders]

    setup_existing_clients
    setup_current_orders
  end

  def setup_existing_clients
    PRIMARY_CLIENTS.each do |client_name|
      cn = client_name.split(' ')
      @db[:Clients].insert(id: @current_client_id, first_name: cn.first, last_name: cn.last)
      @current_client_id += 1
    end
  end

  def setup_current_orders
    CURRENT_ORDERS.each do |order|
      if order[:client_id] && order[:units]
        @db[:Orders].insert(id: @current_order_id, client_id: order[:client_id], units: order[:units])
      end
      @current_order_id += 1
    end
  end
end
