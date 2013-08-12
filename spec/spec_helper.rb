require 'active_record'

TERADATA_CONFIG = {
  :adapter => 'teradata',
  :host => 'localhost',
  :database => 'weblog_development',
  :port => 1025,
  :username => 'dbc',
  :password => 'dbc'
}

TERADATA_JNDI_CONFIG = {
  :adapter => 'teradata',
  :jndi => 'jdbc/TeradataDS',
  :username => 'dbc',
  :password => 'dbc',
  :pool => 20
}

ActiveRecord::Base.establish_connection(TERADATA_CONFIG)
