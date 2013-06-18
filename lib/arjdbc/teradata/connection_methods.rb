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
      config[:tmode] ||= 'ANSI' # ANSI, Teradata, DEFAULT
      config[:charset] ||= 'UTF8'
      config[:cop] ||= 'OFF'
      config[:log_level] ||= 'ERROR'
      config[:url] ||= "jdbc:teradata://#{config[:host]}/DATABASE=#{config[:database]},DBS_PORT=#{config[:port]},COP=#{config[:cop]},tmode=#{config[:tmode]},charset=#{config[:charset]},LOG=#{config[:log_level]}"
      config[:driver] ||= 'com.teradata.jdbc.TeraDriver'
      config[:adapter_class] = ActiveRecord::ConnectionAdapters::TeradataAdapter
      config[:adapter_spec] = ::ArJdbc::Teradata
      jdbc_connection(config)
    end
    alias_method :jdbcteradata_connection, :teradata_connection
  end
end
