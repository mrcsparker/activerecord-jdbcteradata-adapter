class ActiveRecord::Base
  class << self
    def teradata_connection(config)
      config[:port] ||= 1025
      config[:url] ||= "jdbc:teradata://#{config[:host]}/DATABASE=#{config[:database]},DBS_PORT=#{config[:port]},COP=OFF"
      config[:driver] ||= "com.teradata.jdbc.TeraDriver"
      jdbc_connection(config)
    end
    alias_method :jdbcteradata_connection, :teradata_connection
  end
end
