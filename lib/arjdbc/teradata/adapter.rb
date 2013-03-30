require 'arjdbc/mssql/limit_helpers'

module ::ArJdbc
  module Teradata

    def self.column_selector
      [ /teradata/i, lambda { |cfg, column| column.extend(::ArJdbc::Teradata::Column) } ]
    end
    
    #- jdbc_connection_class

    #- jdbc_column_class

    #- jdbc_connection
   
    #- adapter_spec

    #+ modify_types

    #+ adapter_name
    def adapter_name
      'Teradata'
    end

    #- self.visitor_for
    
    #+ self.arel2_visitors
    def self.arel2_visitors(config)
      require 'arel/visitors/teradata'
      {}.tap {|v| %w(teradata jdbcteradata).each {|x| v[x] = ::Arel::Visitors::Teradata } }
    end

    #- configure_arel2_visitors

    #- is_a?

    #+ supports_migrations?
    def supports_migrations?
      true
    end

    #+ native_database_types
    def native_database_types

      super.merge({
        :primary_key => 'INTEGER PRIMARY KEY NOT NULL GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1 MINVALUE -2147483647 MAXVALUE 1000000000 NO CYCLE)',
        :string => { :name => 'VARCHAR', :limit => 255 },
        :integer => { :name => "INTEGER" },
        :float => { :name => "FLOAT" },
        :decimal => { :name => "DECIMAL" },
        :datetime => { :name => "TIMESTAMP" },
        :timestamp => { :name => "TIMESTAMP" },
        :time => { :name => "TIME" },
        :date => { :name => "DATE" },
        :binary => { :name => "BLOB" },
        :boolean => { :name => "BYTEINT", :limit => 1 },
        :raw => { :name => "BYTE" }
      })
    end

    #- database_name

    #- native_sql_to_type

    #- active?

    #- reconnect!

    #- disconnect!

    #- jdbc_columns

    #- exec_query

    #- exec_insert

    #- exec_delete

    #- exec_update

    #+ do_exec

    #- execute
    def _execute(sql, name = nil)
      result = super
      self.class.insert?(sql) ? last_insert_id(_table_name_from_insert(sql)) : result
    end
    private :_execute

    def _table_name_from_insert(sql)
      sql.split(" ", 4)[2].gsub('"', '').gsub("'", "")
    end
    private :_table_name_from_insert

    def last_insert_id(table)
      output = nil
      pk = primary_key(table)
      if pk
        output = execute("SELECT TOP 1 #{pk} FROM #{table} ORDER BY #{pk} DESC").first[pk]
      end
      output
    end

    #- select 

    #- select_rows

    #- insert_sql

    #- tables

    #- table_exists?

    #+ indexes
    # TODO: Multiple indexes per column
    IndexDefinition = ::ActiveRecord::ConnectionAdapters::IndexDefinition # :nodoc:
    def indexes(table_name, name = nil, schema_name = nil)
      result = select_rows("SELECT" <<
                           " DatabaseName, TableName, ColumnName, IndexType, IndexName, UniqueFlag" <<
                           " FROM DBC.Indices" <<
                           " WHERE TableName = '#{table_name}'")
    
      result.map do |row|
        idx_database_name = row[0].to_s.strip
        idx_table_name = row[1].to_s.strip
        idx_column_name = row[2].to_s.strip
        idx_index_type = row[3].to_s.strip
        idx_index_name = row[4].to_s.strip
        idx_unique_flag = row[5].to_s.strip

        columns = []
        columns << idx_column_name

        IndexDefinition.new(idx_table_name, idx_index_name, (idx_unique_flag == "Y"), columns)
      end
    end

    #- begin_db_transaction

    #- commit_db_transaction

    #- rollback_db_transaction

    #- begin_isolated_db_transaction

    #- supports_transaction_isolation?

    #- write_large_object

    #- pk_and_sequence_for
    
    #- primary_key

    #- primary_keys

    #- to_sql

    module Column
      # Maps Teradata types of logical Rails types
      def simplified_type(field_type)
        case field_type
        when /^timestamp with(?:out)? time zone$/ then :datetime
        else
          super
        end
      end
    end # column

    def quote_column_name(name)
      %Q("#{name}")
    end

    def quote_table_name(name)
      name.to_s
    end

  end
end
