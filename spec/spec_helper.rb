require 'active_record'

TERADATA_CONFIG = {
  :adapter => 'teradata',
  :host => 'localhost',
  :database => 'weblog_development',
  :port => 1025,
  :username => 'dbc',
  :password => 'dbc'
}

ActiveRecord::Base.establish_connection(TERADATA_CONFIG)
