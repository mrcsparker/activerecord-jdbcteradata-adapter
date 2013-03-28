require 'rubygems'
require 'active_record'

CONFIG = {
  :username => 'dbc',
  :password => 'dbc',
  :adapter => 'teradata',
  :host => '192.168.5.130',
  :database => 'DBC'
}

ActiveRecord::Base.establish_connection(CONFIG)

class Acct < ActiveRecord::Base
  def self.table_name
    'financial.accts'
  end
end

class CheckingAcct < ActiveRecord::Base
  def self.table_name
    'financial.checking_acct'
  end
end

class CheckingTran < ActiveRecord::Base
  def self.table_name
    'financial.checking_tran'
  end
end

class CreditAcct < ActiveRecord::Base
  def self.table_name
    'financial.credit_acct'
  end
end

class CreditTran < ActiveRecord::Base
  def self.table_name
    'financial.credit_tran'
  end
end

class Customer < ActiveRecord::Base
  def self.table_name
    'financial.customer'
  end
end

class CustomerName < ActiveRecord::Base
  def self.table_name
    'financial.customer_name'
  end
end

class SavingsAcct < ActiveRecord::Base
  def self.table_name
    'financial.savings_acct'
  end
end

class SavingsTran < ActiveRecord::Base
  def self.table_name
    'financial.savings_tran'
  end
end

class Tran < ActiveRecord::Base
  def self.table_name
    'financial.trans'
  end
end
