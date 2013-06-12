require 'arjdbc/mssql/limit_helpers'

module ::ArJdbc
  module Teradata

    require 'arjdbc/jdbc/serialized_attributes_helper'
    ActiveRecord::Base.class_eval do
      def after_save_with_teradata_lob
        lob_columns = self.class.columns.select { |c| c.sql_type =~ /blob|clob/i }
        lob_columns.each do |column|
          value = ::ArJdbc::SerializedAttributesHelper.dump_column_value(self, column)
          next if value.nil? # already set NULL

          self.class.connection.write_large_object(
            column.type == :binary, column.name,
            self.class.table_name,
            self.class.primary_key,
            self.class.connection.quote(id), value
          )
        end
      end
    end

    def self.column_selector
      [ /teradata/i, lambda { |cfg, column| column.extend(::ArJdbc::Teradata::Column) } ]
    end

    ## ActiveRecord::ConnectionAdapters::JdbcAdapter

    #- jdbc_connection_class
    def self.jdbc_connection_class
      ::ActiveRecord::ConnectionAdapters::TeradataJdbcConnection
    end

    #- jdbc_column_class

    #- jdbc_connection

    #- adapter_spec

    #+ modify_types
    def modify_types(types)
      super(types)
      types[:primary_key] = 'INTEGER PRIMARY KEY NOT NULL GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1 MINVALUE -2147483647 MAXVALUE 1000000000 NO CYCLE)',
      types[:string][:limit] = 255
      types[:integer][:limit] = nil
      types
    end

    # Make sure that integer gets specified as INTEGER and not INTEGER(11)
    def type_to_sql(type, limit = nil, precision = nil, scale = nil)
      limit = nil if type.to_sym == :integer
      super(type, limit, precision, scale)
    end

    #+ adapter_name
    def adapter_name
      'Teradata'
    end

    #- self.visitor_for

    #+ self.arel2_visitors
    def self.arel2_visitors(config)
      { 'teradata' => Arel::Visitors::Teradata, 'jdbcteradata' => Arel::Visitors::Teradata }
    end

    #- configure_arel2_visitors

    #- is_a?

    #+ supports_migrations?
    def supports_migrations?
      true
    end

    #+ native_database_types
    def native_database_types
      super.merge(
          {
              :primary_key => 'INTEGER PRIMARY KEY NOT NULL GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1 MINVALUE -2147483647 MAXVALUE 1000000000 NO CYCLE)',
              :string => { :name => 'VARCHAR', :limit => 255 },
              :integer => { :name => 'INTEGER'},
              :float => { :name => 'FLOAT'},
              :decimal => { :name => 'DECIMAL'},
              :datetime => { :name => 'TIMESTAMP'},
              :timestamp => { :name => 'TIMESTAMP'},
              :time => { :name => 'TIMESTAMP'},
              :date => { :name => 'DATE'},
              :binary => { :name => 'BLOB'},
              :boolean => { :name => 'BYTEINT'},
              :raw => { :name => 'BYTE'}
          }
      )
    end

    #- database_name
    def database_name
      @connection.config[:database]
    end

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
      if self.class.select?(sql)
        result = @connection.execute_query(sql)
        result.map! do |r|
          new_hash = {}
          r.each_pair do |k, v|
            new_hash.merge!({k.downcase => v})
          end
          new_hash
        end if self.class.lowercase_schema_reflection
        result
      elsif self.class.insert?(sql)
        (@connection.execute_insert(sql) or last_insert_id(sql)).to_i
      else
        @connection.execute_update(sql)
      end
    end

    def _table_name_from_insert(sql)
      sql.split(' ', 4)[2].gsub('"', '').gsub("'", '')
    end
    private :_table_name_from_insert

    def last_insert_id(table)
      output = nil
      pk = primary_key(table)
      if pk
        output = execute("SELECT TOP 1 #{quote_column_name(pk)} FROM #{quote_table_name(table)} ORDER BY #{quote_column_name(pk)} DESC").first[pk]
      end
      output
    end

    #- select
    def select(sql, *rest)
    # TJC - Teradata does not like "= NULL", "!= NULL", or "<> NULL".
    # TJC - Also does not like != so transforming that to <>
       execute(sql.gsub(/(!=|<>)\s*null/i, "IS NOT NULL").gsub(/=\s*null/i, "IS NULL").gsub("!=","<>"), *rest)
    end

    #- select_rows

    #- insert_sql

    #= extract_schema_and_table (extra, taken from postgresql adapter)
    # Extracts the table and schema name from +name+
    def extract_schema_and_table(name)
      schema, table = name.split('.', 2)

      unless table # A table was provided without a schema
        table  = schema
        schema = nil
      end

      if name =~ /^"/ # Handle quoted table names
        table  = name
        schema = nil
      end
      [schema, table]
    end

    #- tables
    def tables
      @connection.tables(nil, database_name, nil, %w(TABLE))
    end

    #- table_exists?
    def table_exists?(table_name)
      return false unless table_name
      schema, table = extract_schema_and_table(table_name.to_s)
      return false unless table

      schema = database_name unless schema
      output = execute("SELECT count(*) as table_count FROM dbc.tables WHERE TableName = '#{table}' AND DatabaseName = '#{schema}'")
      output.first['table_count'].to_i > 0
    end

    #+ indexes
    # TODO: Multiple indexes per column
    IndexDefinition = ::ActiveRecord::ConnectionAdapters::IndexDefinition # :nodoc:
    def indexes(table_name, name = nil, schema_name = nil)
      return false unless table_name
      schema, table = extract_schema_and_table(table_name.to_s)
      return false unless table

      schema = database_name unless schema

      result = select_rows('SELECT' <<
                           ' DatabaseName, TableName, ColumnName, IndexType, IndexName, UniqueFlag' <<
                           ' FROM DBC.Indices' <<
                           " WHERE TableName = '#{table}' AND DatabaseName = '#{schema}'")

      result.map do |row|
        idx_table_name = row[1].to_s.strip
        idx_column_name = row[2].to_s.strip
        idx_index_name = row[4].to_s.strip
        idx_unique_flag = row[5].to_s.strip

        columns = []
        columns << idx_column_name

        IndexDefinition.new(idx_table_name, idx_index_name, (idx_unique_flag == 'Y'), columns)
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

    ## ConnectionAdapters::Abstract::SchemaStatements

    #- table_exists?

    #- index_exists?

    #- columns
    def columns(table_name, name = nil)
      return false unless table_name
      schema, table = extract_schema_and_table(table_name.to_s)
      return false unless table
      schema = database_name unless schema
      @connection.columns_internal(table, nil, schema)
    end

    #- column_exists?

    #- create_table

    #- change_table

    #+ rename_table

    #- drop_table

    #- add_column

    #- remove_column
    def remove_column(table_name, *column_names) #:nodoc:
      column_names.flatten.each { |column_name|
        execute "ALTER TABLE #{quote_table_name(table_name)} DROP COLUMN #{quote_column_name(column_name)}"
      }
    end

    #+ change_column
    # This only works in a VERY limited fashion.  For example, VARCHAR columns
    # cannot be shortened, one column type cannot be converted to another.
    def change_column(table_name, column_name, type, options = {}) #:nodoc:
      change_column_sql = "ALTER TABLE #{quote_table_name(table_name)} " <<
          "ADD #{quote_column_name(column_name)} #{type_to_sql(type, options[:limit])}"
      add_column_options!(change_column_sql, options)
      execute(change_column_sql)
    end

    #+ change_column_default
    def change_column_default(table_name, column_name, default) #:nodoc:
      execute "ALTER TABLE #{quote_table_name(table_name)} " +
        "ADD #{quote_column_name(column_name)} DEFAULT #{quote(default)}"
    end

    #+ rename_column
    def rename_column(table_name, column_name, new_column_name) #:nodoc:
      execute "ALTER TABLE #{quote_table_name(table_name)} " <<
                  "RENAME COLUMN #{quote_column_name(column_name)} to #{quote_column_name(new_column_name)}"
    end

    #- add_index

    #- remove_index

    #- rename_index

    #- index_name

    #- index_name_exists?

    #+ structure_dump

    #- dump_schema_information

    #- initialize_schema_migrations_table

    #- assume_migrated_upto_version

    #- type_to_sql

    #- add_column_options!

    #- distinct

    #- add_timestamps

    #- remove_timestamps

    module Column
      # Maps Teradata types of logical Rails types
      def simplified_type(field_type)
        case field_type
          when /^timestamp with(?:out)? time zone$/ then :datetime
          when /byteint/i then :boolean
          else
            super
        end
      end
    end # column

    def type_cast
      return super unless value == true || value == false

      value ? 1 : 0
    end

    def quote(value, column = nil)
      return value.quoted_id if value.respond_to?(:quoted_id)
      case value
        when String
          %Q{'#{quote_string(value)}'}
        when TrueClass
          '1'
        when FalseClass
          '0'
        else super
      end
    end

    def quote_column_name(name)
      %Q("#{name}")
    end

    def quote_table_name(name)
      %Q("#{name.to_s}")
    end

    def quote_true
      '1'
    end

    def quoted_false
      '0'
    end

    def add_index(table_name, column_name, options = {})
      index_name, index_type, index_columns = add_index_options(table_name, column_name, options)
      execute "CREATE #{index_type} INDEX #{quote_column_name(index_name)} (#{index_columns}) ON #{quote_table_name(table_name)}"
    end

    IDENTIFIER_LENGTH = 30 # :nodoc:

    # maximum length of Teradata identifiers is 30
    def table_alias_length; IDENTIFIER_LENGTH
    end # :nodoc:
    def table_name_length;  IDENTIFIER_LENGTH
    end # :nodoc:
    def index_name_length;  IDENTIFIER_LENGTH
    end # :nodoc:
    def column_name_length; IDENTIFIER_LENGTH
    end # :nodoc:

  end
end

module ActiveRecord
  module ConnectionAdapters
    class TeradataColumn < JdbcColumn
      include ::ArJdbc::Teradata::Column

      def initialize(name, *args)

        if Hash === name
          if name.has_key? :adapter_class
            args[0].downcase! if name[:adapter_class].lowercase_schema_reflection
          end
          super
        else
          super(nil, name, *args)
        end
      end

      def call_discovered_column_callbacks(*)
      end
    end

    class TeradataAdapter < JdbcAdapter
      include ::ArJdbc::Teradata

      cattr_accessor :lowercase_schema_reflection

      def initialize(*args)
        super
      end

      def jdbc_connection_class(spec)
        ::ArJdbc::Teradata.jdbc_connection_class
      end

      def jdbc_column_class
        TeradataColumn
      end
      alias_chained_method :columns, :query_cache, :jdbc_columns

      # some QUOTING caching :

      @@quoted_table_names = {}

      def quote_table_name(name)
        unless quoted = @@quoted_table_names[name]
          quoted = quote_column_name(name).gsub('.', '"."')
          @@quoted_table_names[name] = quoted.freeze
        end
        quoted
      end

      @@quoted_column_names = {}

      def quote_column_name(name)
        unless quoted = @@quoted_column_names[name]
          quoted = super
          @@quoted_column_names[name] = quoted.freeze
        end
        quoted
      end
    end

  end
end

