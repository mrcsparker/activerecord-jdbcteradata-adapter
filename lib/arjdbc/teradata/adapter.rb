require 'arjdbc/mssql/limit_helpers'

module ::ArJdbc
  module Teradata

    def self.jdbc_connection_class
      ::ActiveRecord::ConnectionAdapters::TeradataRubyJdbcConnection
    end

    def adapter_name
      'Teradata'
    end

    def self.arel2_visitors(config)
      require 'arel/visitors/teradata'
      {}.tap {|v| %w(teradata jdbcteradata).each {|x| v[x] = ::Arel::Visitors::Teradata } }
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

    def determine_order_clause(sql)
      return $1 if sql =~ /ORDER BY (.*)$/
      table_name = get_table_name(sql)
      "#{table_name}.#{determine_primary_key(table_name)}"
    end

    def determine_primary_key(table_name)
      primary_key = columns(table_name).detect { |column| column.primary }
      return primary_key.name if primary_key
      # Look for an id column.  Return it, without changing case, to cover dbs with a case-sensitive collation.
      columns(table_name).each { |column| return column.name if column.name =~ /^id$/i }
      # Give up and provide something which is going to crash almost certainly
      columns(table_name)[0].name
    end

    def get_table_name(sql)
      if sql =~ /^\s*insert\s+into\s+([^\(\s,]+)\s*|^\s*update\s+([^\(\s,]+)\s*/i
        $1
      elsif sql =~ /\bfrom\s+([^\(\s,]+)\s*/i
        $1
      else
        nil
      end
    end
  end
end
