class ActiveRecord::Base
  class << self
    def teradata_connection(config)
      begin
        require 'jdbc/teradata'
        ::Jdbc::Teradata.load_driver(:require) if defined?(::Jdbc::Teradata.load_driver)
      rescue LoadError # assuming driver.jar is on the class-path
      end

      if config[:jndi]
        jndi = config[:jndi].to_s
        ctx = javax.naming.InitialContext.new
        ds = nil

        # Taken from oracle-enhanced (https://github.com/rsim/oracle-enhanced)
        # tomcat needs first lookup method, oc4j (and maybe other application servers) need second method
        begin
          env = ctx.lookup('java:/comp/env')
          ds = env.lookup(jndi)
        rescue
          ds = ctx.lookup(jndi)
        end

        # For ARJDBC we only need the URL, username, and password
        # We set the database config entry because it's used by the adapter to determine database_name
        if ds.respond_to?('getJdbcUrl')
          config[:url] = ds.getJdbcUrl
        else
          config[:url] = ds.getUrl
        end
        config[:username] ||= ds.getUsername
        config[:database] ||= config[:url][/DATABASE=(.*?),/m, 1] unless config[:url].nil?
        config[:password] ||= ds.getPassword

      else
        config[:username] ||= Java::JavaLang::System.get_property('user.name')
        config[:host] ||= 'localhost'
        config[:port] ||= 1025
        config[:tmode] ||= 'ANSI' # ANSI, Teradata, DEFAULT
        config[:charset] ||= 'UTF8'
        config[:cop] ||= 'OFF'
        config[:log_level] ||= 'ERROR'
        config[:xviews] ||= 'OFF'
        config[:url] ||= "jdbc:teradata://#{config[:host]}/DATABASE=#{config[:database]},DBS_PORT=#{config[:port]},COP=#{config[:cop]},tmode=#{config[:tmode]},charset=#{config[:charset]},LOG=#{config[:log_level]},USEXVIEWS=#{config[:xviews]}"
      end
        config[:driver] ||= 'com.teradata.jdbc.TeraDriver'
        config[:adapter_class] = ActiveRecord::ConnectionAdapters::TeradataAdapter
        config[:adapter_spec] = ::ArJdbc::Teradata
        jdbc_connection(config)
    end

    alias_method :jdbcteradata_connection, :teradata_connection
  end
end
