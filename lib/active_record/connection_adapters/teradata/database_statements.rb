# module ActiveRecord
#   module ConnectionAdapters
#     module Teradata
#       module DatabaseStatements

#         puts "include"

#         def select_rows(sql, name = nil)
#           puts "in select rows"
#           raw_select sql, name, [], :fetch => :rows
#         end

#         protected

#         def raw_select(sql, name='SQL', binds=[], options={})
#           log(sql,name,binds) { _raw_select(sql, options) }
#         end

#         def _raw_select(sql, options={})
#           begin
#             handle = @connection.execute(sql)
#             handle_to_names_and_values(handle, options)
#           ensure
#             handle.cancel if handle
#             handle
#           end
#         end

#         def handle_to_names_and_values(handle, options)
#           @connection.use_utc = ActiveRecord::Base.default_timezone == :utc

#           if options[:ar_result]
#             #columns = lowercase_schema_reflection ? handle.columns(true).map { |c| c.name.downcase } : handle.columns(true).map { |c| c.name }
#             columns = handle.columns(true).map { |c| c.name.downcase }
#             rows = handle.fetch_all || []
#             ActiveRecord::Result.new(columns, rows)
#           else
#             case options[:fetch]
#             when :all
#               handle.each_hash || []
#             when :rows
#               handle.fetch_all || []
#             end
#           end
#         end

#       end
#     end
#   end
# end
