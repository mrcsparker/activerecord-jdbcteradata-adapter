module ::ArJdbc
  module Teradata

    def self.jdbc_connection_class
      ::ActiveRecord::ConnectionAdapters::TeradataJdbcConnection
    end

    def adapter_name
      'Teradata'
    end
  end
end
