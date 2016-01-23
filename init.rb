$:.unshift '.'

# setup test suite
require 'minitest/autorun'

# external libs
require 'rubygems'
require 'sequel'
require 'active_support/all'

# internal libs
require 'lib/db'
require 'lib/test_helper'

# Allows True & False respond to Boolean
module Boolean
end
class TrueClass
  include Boolean
end
class FalseClass
  include Boolean
end

class TestClass < MiniTest::Test
  include TestHelper
end
