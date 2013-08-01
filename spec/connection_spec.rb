require 'spec_helper'
require 'java'
require 'commons-pool-1.6.jar'
require 'commons-dbcp-1.4.jar'

describe 'Connection' do
  it 'should create a connection' do
    ActiveRecord::Base.connection.execute('select * from dbc.tables')
    ActiveRecord::Base.connected?.should be_true
  end

  it "should create a new connection using JNDI" do
    begin
      import 'org.apache.commons.pool.impl.GenericObjectPool'
      import 'org.apache.commons.dbcp.PoolingDataSource'
      import 'org.apache.commons.dbcp.PoolableConnectionFactory'
      import 'org.apache.commons.dbcp.DriverManagerConnectionFactory'
    rescue NameError => e
      return pending e.message
    end

    class InitialContextMock
      def initialize
        connection_pool = GenericObjectPool.new(nil)
        uri = "jdbc:teradata://#{TERADATA_CONFIG[:host]}/DATABASE=#{TERADATA_CONFIG[:database]},DBS_PORT=#{TERADATA_CONFIG[:port]}"
        connection_factory = DriverManagerConnectionFactory.new(uri, TERADATA_CONFIG[:username], TERADATA_CONFIG[:password])
        poolable_connection_factory = PoolableConnectionFactory.new(connection_factory,connection_pool,nil,nil,false,true)
        @data_source = PoolingDataSource.new(connection_pool)
        @data_source.access_to_underlying_connection_allowed = true
      end
      def lookup(path)
        if (path == 'java:/comp/env')
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
