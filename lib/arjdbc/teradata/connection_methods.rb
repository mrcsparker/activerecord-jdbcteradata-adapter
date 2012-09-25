class ActiveRecord::Base
  class Base
    class << self
      def teradata_connection
        config[:port] ||= 1025
        config[:url] ||= "jdbc:teradata://#{config[:host]}/DATABASE=#{config[:database]},DBS_PORT=#{config[:port]},COP=OFF"
        config[:driver] ||= "com.teradata.jdbc.TeraDriver"
        config[:adapter_spec] = ::ArJdbc::Teradata
        embedded_driver(config)
      end
      alias_method :jdbcteradata_connection, :teradata_connection
    end
  end
end
