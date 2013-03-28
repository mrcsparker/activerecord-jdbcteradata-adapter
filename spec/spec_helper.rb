require 'active_record'

TERADATA_CONFIG = {
  :adapter => 'teradata',
  :host => '192.168.5.130',
  :database => 'weblog_development',
  :port => 1025,
  :username => 'dbc',
  :password => 'dbc'
}

ActiveRecord::Base.establish_connection(TERADATA_CONFIG)
