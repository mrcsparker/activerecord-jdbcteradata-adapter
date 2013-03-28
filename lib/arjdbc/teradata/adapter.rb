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
        :primary_key => 'INTEGER PRIMARY KEY NOT NULL GENERATED ALWAYS AS IDENTITY',
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

    # <Helpers>

    def get_table_name(sql)
      if sql =~ /^\s*insert\s+into\s+([^\(\s,]+)\s*|^\s*update\s+([^\(\s,]+)\s*/i
        $1
      elsif sql =~ /\bfrom\s+([^\(\s,]+)\s*/i
        $1
      else
        nil
      end
    end

    def determine_order_clause(sql)
      return $1 if sql =~ /ORDER BY (.*)$/
      table_name = get_table_name(sql)
      "#{table_name}.#{determine_primary_key(table_name)}"
    end

    def determine_primary_key(table_name)
      table_name = table_name.gsub('"', '')
      primary_key = columns(table_name).detect { |column| column.primary }
      return primary_key.name if primary_key
      # Look for an id column.  Return it, without changing case, to cover dbs with a case-sensitive collation.
      columns(table_name).each { |column| return column.name if column.name =~ /^id$/i }
      # Give up and provide something which is going to crash almost certainly
      columns(table_name)[0].name
    end

    def add_limit_offset!(sql, options)
      if options[:limit]
        order = "ORDER BY #{options[:order] || determine_order_clause(sql)}"
        sql.sub!(/ ORDER BY.*$/i, '')
        replace_limit_offset!(sql, options[:limit], options[:offset], order)
      end
    end

    def replace_limit_offset!(sql, limit, offset, order)
      if limit
        offset ||= 0
        start_row = offset + 1
        end_row = offset + limit.to_i
        find_select = /\b(SELECT(?:\s+DISTINCT)?)\b(.*)/im
        whole, select, rest_of_query = find_select.match(sql).to_a
        rest_of_query.strip!
        if rest_of_query[0...1] == "1" && rest_of_query !~ /1 AS/i
          rest_of_query[0] = "*"
        end
        if rest_of_query[0] == "*"
          from_table = get_table_name(rest_of_query)
          rest_of_query = from_table + '.' + rest_of_query
        end
        new_sql = "#{select} t.* FROM (SELECT ROW_NUMBER() OVER(#{order}) AS _row_num, #{rest_of_query}"
        new_sql << ") AS t WHERE t._row_num BETWEEN #{start_row.to_s} AND #{end_row.to_s}"
        sql.replace(new_sql)
      end
      sql
    end

    # </Helpers>

  end
end
