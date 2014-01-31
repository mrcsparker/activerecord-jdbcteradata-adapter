require 'spec_helper'
require 'java'
require 'commons-pool-1.6.jar'
require 'commons-dbcp-1.4.jar'

describe 'Connection' do
  it 'should create a connection' do
    ActiveRecord::Base.connection.execute('select * from dbc.tables')
    ActiveRecord::Base.connected?.should be_true
  end

  it 'should create a new connection using JNDI' do
    begin
      import 'org.apache.commons.pool.impl.GenericObjectPool'
      import 'org.apache.commons.dbcp.BasicDataSource'
      import 'org.apache.commons.dbcp.BasicDataSourceFactory'
      import 'org.apache.commons.dbcp.DriverManagerConnectionFactory'
    rescue NameError => e
      return pending e.message
    end

    class InitialContextMock
      def initialize
        url = "jdbc:teradata://#{TERADATA_CONFIG[:host]}/DATABASE=#{TERADATA_CONFIG[:database]},DBS_PORT=#{TERADATA_CONFIG[:port]}"
        @data_source = BasicDataSource.new
        @data_source.set_driver_class_name('com.teradata.jdbc.TeraDriver')
        @data_source.set_url(url)
        @data_source.set_username(TERADATA_CONFIG[:username])
        @data_source.set_password(TERADATA_CONFIG[:password])

        @data_source.access_to_underlying_connection_allowed = true
      end

      def lookup(path)
        if path == 'java:/comp/env'
          return self
        else
          return @data_source
        end
      end
    end

    javax.naming.InitialContext.stub!(:new).and_return(InitialContextMock.new)

    ActiveRecord::Base.establish_connection(TERADATA_JNDI_CONFIG)
    ActiveRecord::Base.connection.execute('select * from dbc.tables')
    ActiveRecord::Base.connected?.should be_true
  end
end
