module ::ArJdbc
  module Teradata
    def supports_explain?
      true
    end

    def explain(arel, binds = [])
      sql = "EXPLAIN #{to_sql(arel, binds)}"
      raw_result  = @connection.execute_query(sql)
      raw_result
      rows = raw_result.map { |hash| hash.values }
      rows.join("\n")
    end
  end
end
