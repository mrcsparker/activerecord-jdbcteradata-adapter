module Arel
  module Visitors
    class Teradata < Arel::Visitors::ToSql

      def visit_Arel_Nodes_SelectStatement o
        if !o.limit && o.offset
          raise ActiveRecord::ActiveRecordError, "You must specify :limit with :offset."
        end
        order = "ORDER BY #{o.orders.map { |x| visit x }.join(', ')}" unless o.orders.empty?
        if o.limit
          if select_count?(o)
            subquery = true
            sql = o.cores.map do |x|
              x = x.dup
              x.projections = [Arel::Nodes::SqlLiteral.new("*")]
              visit_Arel_Nodes_SelectCore x
            end.join
          else
            sql = o.cores.map { |x| visit_Arel_Nodes_SelectCore x }.join
          end

          order ||= "ORDER BY #{determine_order_clause(sql)}"
          replace_limit_offset!(sql, limit_for(o.limit).to_i, o.offset && o.offset.value.to_i, order)
          sql = "SELECT COUNT(*) AS count_id FROM (#{sql}) AS subquery" if subquery
        else
          sql = super
        end

        sql
      end

      # <Helpers>
      # Lots of this code was pulled from the activerecord JDBC MSSQL driver

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
        primary_key = @connection.columns(table_name).detect { |column| column.primary }
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

      def limit_for(limit_or_node)
        limit_or_node.respond_to?(:expr) ? limit_or_node.expr.to_i : limit_or_node
      end

      def select_count? o
        sel = o.cores.length == 1 && o.cores.first
        projections = sel && sel.projections.length == 1 && sel.projections
        projections && Arel::Nodes::Count === projections.first
      end

      # </Helpers>

    end
  end
end
