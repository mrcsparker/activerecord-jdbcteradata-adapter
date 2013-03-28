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
  self.table_name = 'financial.accts'
  
  belongs_to :customer, :foreign_key => 'cust_id'
end

class CheckingAcct < ActiveRecord::Base
  self.table_name = 'financial.checking_acct'
  self.primary_key = 'cust_id'

  belongs_to :customer, :foreign_key => 'cust_id'
end

class CheckingTran < ActiveRecord::Base
  self.table_name = 'financial.checking_tran'
  self.primary_key = 'Tran_Id'

  belongs_to :customer, :foreign_key => 'Cust_Id'
end

class CreditAcct < ActiveRecord::Base
  self.table_name = 'financial.credit_acct'
  self.primary_key = 'cust_id'

  belongs_to :customer, :foreign_key => 'cust_id'
end

class CreditTran < ActiveRecord::Base
  self.table_name ='financial.credit_tran'
  self.primary_key = 'Tran_Id'

  belongs_to :customer, :foreign_key => 'Cust_Id'
end

class Customer < ActiveRecord::Base
  self.table_name = 'financial.customer'
  self.primary_key = 'cust_id'
end

class CustomerName < ActiveRecord::Base
  self.table_name = 'financial.customer_name'
  self.primary_key = 'cust_id'

  belongs_to :customer, :foreign_key => 'cust_id'
end

class SavingsAcct < ActiveRecord::Base
  self.table_name = 'financial.savings_acct'
  self.primary_key = 'cust_id'

  belongs_to :customer, :foreign_key => 'cust_id'
end

class SavingsTran < ActiveRecord::Base
  self.table_name = 'financial.savings_tran'
  self.primary_key = 'Tran_Id'

  belongs_to :customer, :foreign_key => 'Cust_Id'
end

class Tran < ActiveRecord::Base
  self.table_name = 'financial.trans'
end
