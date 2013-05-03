class ActiveRecord::Base
  class << self
    def teradata_connection(config)
      begin
        require 'jdbc/teradata'
        ::Jdbc::Teradata.load_driver(:require) if defined?(::Jdbc::Teradata.load_driver)
      rescue LoadError # assuming driver.jar is on the class-path
      end

      config[:username] ||= Java::JavaLang::System.get_property('user.name')
      config[:host] ||= 'localhost'
      config[:port] ||= 1025
      config[:url] ||= "jdbc:teradata://#{config[:host]}/DATABASE=#{config[:database]},DBS_PORT=#{config[:port]},COP=OFF"
      config[:driver] ||= 'com.teradata.jdbc.TeraDriver'
      config[:adapter_class] = ActiveRecord::ConnectionAdapters::TeradataAdapter
      config[:adapter_spec] = ::ArJdbc::Teradata
      jdbc_connection(config)
    end
    alias_method :jdbcteradata_connection, :teradata_connection
  end
end
