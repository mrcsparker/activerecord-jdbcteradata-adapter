package arjdbc.teradata;

import arjdbc.jdbc.RubyJdbcConnection;
import arjdbc.jdbc.SQLBlock;
import org.jruby.*;
import org.jruby.anno.JRubyMethod;
import org.jruby.runtime.ObjectAllocator;
import org.jruby.runtime.ThreadContext;
import org.jruby.runtime.builtin.IRubyObject;

import java.io.*;
import java.lang.reflect.InvocationTargetException;
import java.math.BigDecimal;
import java.math.BigInteger;
import java.sql.*;
import java.util.Calendar;
import java.util.List;

/**
 * Pulled most of this code from RubyJdbcConnection.java master, updated for Teradata,
 * and renamed it so that there wouldn't be any future conflicts.  Once the code
 * in master is ready, this can be removed.
 */

public class TeradataRubyJdbcConnection extends RubyJdbcConnection {

    protected TeradataRubyJdbcConnection(Ruby runtime, RubyClass metaClass) {
        super(runtime, metaClass);
    }

    @Override
    protected boolean databaseSupportsSchemas() {
        return true;
    }

    public static RubyClass createTeradataJdbcConnectionClass(Ruby runtime, RubyClass jdbcConnection) {
        RubyClass clazz = RubyJdbcConnection.getConnectionAdapters(runtime).
            defineClassUnder("TeradataJdbcConnection", jdbcConnection, Teradata_JDBCCONNECTION_ALLOCATOR);
        clazz.defineAnnotatedMethods(TeradataRubyJdbcConnection.class);
        getConnectionAdapters(runtime).setConstant("TeradataJdbcConnection", clazz); // backwards-compat
        return clazz;
    }

    private static ObjectAllocator Teradata_JDBCCONNECTION_ALLOCATOR = new ObjectAllocator() {
        public IRubyObject allocate(Ruby runtime, RubyClass klass) {
            return new TeradataRubyJdbcConnection(runtime, klass);
        }
    };

    @JRubyMethod(name = "print_stuff")
    public void print_stuff(final ThreadContext context) {
        System.out.println("Stuff");
    }

    public IRubyObject insertBatch(final ThreadContext context, final String sql, final List binds) throws SQLException {
        final Ruby runtime = context.getRuntime();
        return (IRubyObject) withConnectionAndRetry(context, new SQLBlock() {
            public Object call(final Connection connection) throws SQLException {
                PreparedStatement prepStatement = null;
                try {
                    connection.setAutoCommit(false);
                    prepStatement = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
                    setTeradataStatementParameters(context, connection, prepStatement, binds);
                    prepStatement.executeBatch();
                    connection.commit();
                    connection.setAutoCommit(true);
                    return unmarshal_id_result(runtime, prepStatement.getGeneratedKeys());
                } finally {
                    close(prepStatement);
                }
            }
        });
    }

    void setTeradataStatementParameters(final ThreadContext context,
                                        final Connection connection, final PreparedStatement statement,
                                        final List binds) throws SQLException {

        final Ruby runtime = context.getRuntime();

        for (int i = 0; i < binds.size(); i++) {
            // [ [ column1, param1 ], [ column2, param2 ], ... ]
            Object param = binds.get(i);
            IRubyObject column = null;
            if (param.getClass() == RubyArray.class) {
                final RubyArray _param = (RubyArray) param;
                column = _param.eltInternal(0);
                param = _param.eltInternal(1);
            } else if (param instanceof List) {
                final List<?> _param = (List<?>) param;
                column = (IRubyObject) _param.get(0);
                param = _param.get(1);
            } else if (param instanceof Object[]) {
                final Object[] _param = (Object[]) param;
                column = (IRubyObject) _param[0];
                param = _param[1];
            }

            final IRubyObject type;
            if (column != null && !column.isNil()) {
                type = column.callMethod(context, "type");
            } else {
                type = null;
            }

            setTeradataStatementParameter(context, runtime, connection, statement, i + 1, param, type);
            statement.addBatch();
        }
    }

    void setTeradataStatementParameter(final ThreadContext context,
                                       final Ruby runtime, final Connection connection,
                                       final PreparedStatement statement, final int index,
                                       final Object value, final IRubyObject column) throws SQLException {

        final RubySymbol columnType = resolveColumnType(context, runtime, column);
        final int type = jdbcTypeFor(runtime, column, columnType, value);

        // TODO pass column with (JDBC) type to methods :

        switch (type) {
            case Types.TINYINT:
            case Types.SMALLINT:
            case Types.INTEGER:
                if (value instanceof RubyBignum) {
                    setTeradataBigIntegerParameter(runtime, connection, statement, index, type, (RubyBignum) value);
                }
                setTeradataIntegerParameter(runtime, connection, statement, index, type, value);
                break;
            case Types.BIGINT:
                setTeradataBigIntegerParameter(runtime, connection, statement, index, type, value);
                break;
            case Types.REAL:
            case Types.FLOAT:
            case Types.DOUBLE:
                setTeradataDoubleParameter(runtime, connection, statement, index, type, value);
                break;
            case Types.NUMERIC:
            case Types.DECIMAL:
                setTeradataDecimalParameter(runtime, connection, statement, index, type, value);
                break;
            case Types.DATE:
                setDateParameter(runtime, connection, statement, index, type, value);
                break;
            case Types.TIME:
                setTimeParameter(runtime, connection, statement, index, type, value);
                break;
            case Types.TIMESTAMP:
                setTeradataTimestampParameter(runtime, connection, statement, index, type, value);
                break;
            case Types.BIT:
            case Types.BOOLEAN:
                setTeradataBooleanParameter(runtime, connection, statement, index, type, value);
                break;
            case Types.SQLXML:
                setTeradataXmlParameter(runtime, connection, statement, index, type, value);
                break;
            case Types.ARRAY:
                setTeradataArrayParameter(runtime, connection, statement, index, type, value);
                break;
            case Types.JAVA_OBJECT:
            case Types.OTHER:
                setTeradataObjectParameter(runtime, connection, statement, index, type, value);
                break;
            case Types.BINARY:
            case Types.VARBINARY:
            case Types.LONGVARBINARY:
            case Types.BLOB:
                setTeradataBlobParameter(runtime, connection, statement, index, type, value);
                break;
            case Types.CLOB:
            case Types.NCLOB: // JDBC 4.0
                setTeradataClobParameter(runtime, connection, statement, index, type, value);
                break;
            case Types.CHAR:
            case Types.VARCHAR:
            case Types.NCHAR: // JDBC 4.0
            case Types.NVARCHAR: // JDBC 4.0
            default:
                setTeradataStringParameter(runtime, connection, statement, index, type, value);
        }
    }

    private RubySymbol resolveColumnType(final ThreadContext context, final Ruby runtime,
                                         final IRubyObject column) {
        if (column instanceof RubySymbol) { // deprecated behavior
            return (RubySymbol) column;
        }
        if (column instanceof RubyString) { // deprecated behavior
            if (runtime.is1_9()) {
                return ((RubyString) column).intern19();
            } else {
                return ((RubyString) column).intern();
            }
        }

        if (column == null || column.isNil()) {
            throw runtime.newArgumentError("nil column passed");
        }
        return (RubySymbol) column.callMethod(context, "type");
    }

    /* protected */ int jdbcTypeFor(final Ruby runtime, final IRubyObject column,
                                    final RubySymbol columnType, final Object value) throws SQLException {

        final String internedType = columnType.asJavaString();

        if (internedType == (Object) "string") return Types.VARCHAR;
        else if (internedType == (Object) "text") return Types.CLOB;
        else if (internedType == (Object) "integer") return Types.INTEGER;
        else if (internedType == (Object) "decimal") return Types.DECIMAL;
        else if (internedType == (Object) "float") return Types.FLOAT;
        else if (internedType == (Object) "date") return Types.DATE;
        else if (internedType == (Object) "time") return Types.TIME;
        else if (internedType == (Object) "datetime") return Types.TIMESTAMP;
        else if (internedType == (Object) "timestamp") return Types.TIMESTAMP;
        else if (internedType == (Object) "binary") return Types.BLOB;
        else if (internedType == (Object) "boolean") return Types.BOOLEAN;
        else if (internedType == (Object) "xml") return Types.SQLXML;
        else if (internedType == (Object) "array") return Types.ARRAY;
        else return Types.OTHER; // -1 as well as 0 are used in Types
    }

    /* protected */ void setTeradataIntegerParameter(final Ruby runtime, final Connection connection,
                                                     final PreparedStatement statement, final int index, final int type,
                                                     final Object value) throws SQLException {
        if (value instanceof IRubyObject) {
            setTeradataIntegerParameter(runtime, connection, statement, index, type, (IRubyObject) value);
        } else {
            if (value == null) statement.setNull(index, Types.INTEGER);
            else {
                statement.setLong(index, ((Number) value).longValue());
            }
        }
    }

    /* protected */ void setTeradataIntegerParameter(final Ruby runtime, final Connection connection,
                                                     final PreparedStatement statement, final int index, final int type,
                                                     final IRubyObject value) throws SQLException {
        if (value.isNil()) statement.setNull(index, Types.INTEGER);
        else {
            if (value instanceof RubyFixnum) {
                statement.setLong(index, ((RubyFixnum) value).getLongValue());
            } else {
                statement.setInt(index, RubyNumeric.fix2int(value));
            }
        }
    }

    /* protected */ void setTeradataBigIntegerParameter(final Ruby runtime, final Connection connection,
                                                        final PreparedStatement statement, final int index, final int type,
                                                        final Object value) throws SQLException {
        if (value instanceof IRubyObject) {
            setTeradataBigIntegerParameter(runtime, connection, statement, index, type, (IRubyObject) value);
        } else {
            if (value == null) statement.setNull(index, Types.BIGINT);
            else {
                if (value instanceof BigDecimal) {
                    statement.setBigDecimal(index, (BigDecimal) value);
                } else if (value instanceof BigInteger) {
                    setTeradataLongOrDecimalParameter(statement, index, (BigInteger) value);
                } else {
                    statement.setLong(index, ((Number) value).longValue());
                }
            }
        }
    }

    /* protected */ void setTeradataBigIntegerParameter(final Ruby runtime, final Connection connection,
                                                        final PreparedStatement statement, final int index, final int type,
                                                        final IRubyObject value) throws SQLException {
        if (value.isNil()) statement.setNull(index, Types.INTEGER);
        else {
            if (value instanceof RubyBignum) {
                setTeradataLongOrDecimalParameter(statement, index, ((RubyBignum) value).getValue());
            } else {
                statement.setLong(index, ((RubyInteger) value).getLongValue());
            }
        }
    }

    private static final BigInteger MAX_LONG = BigInteger.valueOf(Long.MAX_VALUE);
    private static final BigInteger MIN_LONG = BigInteger.valueOf(Long.MIN_VALUE);

    /* protected */
    static void setTeradataLongOrDecimalParameter(final PreparedStatement statement,
                                                  final int index, final BigInteger value) throws SQLException {
        if (value.compareTo(MAX_LONG) <= 0 // -1 intValue < MAX_VALUE
                && value.compareTo(MIN_LONG) >= 0) {
            statement.setLong(index, value.longValue());
        } else {
            statement.setBigDecimal(index, new BigDecimal(value));
        }
    }

    /* protected */ void setTeradataDoubleParameter(final Ruby runtime, final Connection connection,
                                                    final PreparedStatement statement, final int index, final int type,
                                                    final Object value) throws SQLException {
        if (value instanceof IRubyObject) {
            setTeradataDoubleParameter(runtime, connection, statement, index, type, (IRubyObject) value);
        } else {
            if (value == null) statement.setNull(index, Types.DOUBLE);
            else {
                statement.setDouble(index, ((Number) value).doubleValue());
            }
        }
    }

    /* protected */ void setTeradataDoubleParameter(final Ruby runtime, final Connection connection,
                                                    final PreparedStatement statement, final int index, final int type,
                                                    final IRubyObject value) throws SQLException {
        if (value.isNil()) statement.setNull(index, Types.DOUBLE);
        else {
            statement.setDouble(index, ((RubyNumeric) value).getDoubleValue());
        }
    }

    /* protected */ void setTeradataDecimalParameter(final Ruby runtime, final Connection connection,
                                                     final PreparedStatement statement, final int index, final int type,
                                                     final Object value) throws SQLException {
        if (value instanceof IRubyObject) {
            setTeradataDecimalParameter(runtime, connection, statement, index, type, (IRubyObject) value);
        } else {
            if (value == null) statement.setNull(index, Types.DECIMAL);
            else {
                if (value instanceof BigDecimal) {
                    statement.setBigDecimal(index, (BigDecimal) value);
                } else if (value instanceof BigInteger) {
                    setTeradataLongOrDecimalParameter(statement, index, (BigInteger) value);
                } else {
                    statement.setDouble(index, ((Number) value).doubleValue());
                }
            }
        }
    }

    /* protected */ void setTeradataDecimalParameter(final Ruby runtime, final Connection connection,
                                                     final PreparedStatement statement, final int index, final int type,
                                                     final IRubyObject value) throws SQLException {
        if (value.isNil()) statement.setNull(index, Types.DECIMAL);
        else {
            // NOTE: RubyBigDecimal moved into org.jruby.ext.bigdecimal (1.6 -> 1.7)
            if (value.getMetaClass().getName().indexOf("BigDecimal") != -1) {
                try { // reflect ((RubyBigDecimal) value).getValue() :
                    BigDecimal decValue = (BigDecimal) value.getClass().
                            getMethod("getValue", (Class<?>[]) null).
                            invoke(value, (Object[]) null);
                    statement.setBigDecimal(index, decValue);
                } catch (NoSuchMethodException e) {
                    throw new RuntimeException(e);
                } catch (IllegalAccessException e) {
                    throw new RuntimeException(e);
                } catch (InvocationTargetException e) {
                    throw new RuntimeException(e.getCause() != null ? e.getCause() : e);
                }
            } else {
                statement.setDouble(index, ((RubyNumeric) value).getDoubleValue());
            }
        }
    }

    /* protected */ void setTeradataTimestampParameter(final Ruby runtime, final Connection connection,
                                                       final PreparedStatement statement, final int index, final int type,
                                                       final Object value) throws SQLException {
        if (value instanceof IRubyObject) {
            setTeradataTimestampParameter(runtime, connection, statement, index, type, (IRubyObject) value);
        } else {
            if (value == null) statement.setNull(index, Types.TIMESTAMP);
            else {
                if (value instanceof Timestamp) {
                    statement.setTimestamp(index, (Timestamp) value);
                } else if (value instanceof java.util.Date) {
                    statement.setTimestamp(index, new Timestamp(((java.util.Date) value).getTime()));
                } else {
                    statement.setTimestamp(index, Timestamp.valueOf(value.toString()));
                }
            }
        }
    }

    /* protected */ void setTeradataTimestampParameter(final Ruby runtime, final Connection connection,
                                                       final PreparedStatement statement, final int index, final int type,
                                                       final IRubyObject value) throws SQLException {
        if (value.isNil()) statement.setNull(index, Types.TIMESTAMP);
        else {
            if (value instanceof RubyTime) {
                final RubyTime timeValue = (RubyTime) value;
                final java.util.Date dateValue = timeValue.getJavaDate();

                long millis = dateValue.getTime();
                Timestamp timestamp = new Timestamp(millis);
                Calendar calendar = Calendar.getInstance();
                calendar.setTime(dateValue);
                if (type != Types.DATE) {
                    int micros = (int) timeValue.microseconds();
                    timestamp.setNanos(micros * 1000); // time.nsec ~ time.usec * 1000
                }
                statement.setTimestamp(index, timestamp, calendar);
            } else {
                final String stringValue = value.convertToString().toString();
                // yyyy-[m]m-[d]d hh:mm:ss[.f...]
                final Timestamp timestamp = Timestamp.valueOf(stringValue);
                statement.setTimestamp(index, timestamp, Calendar.getInstance());
            }
        }
    }

    /* protected */ void setTimeParameter(final Ruby runtime, final Connection connection,
                                          final PreparedStatement statement, final int index, final int type,
                                          final Object value) throws SQLException {
        if (value instanceof IRubyObject) {
            setTimeParameter(runtime, connection, statement, index, type, (IRubyObject) value);
        } else {
            if (value == null) statement.setNull(index, Types.TIME);
            else {
                if (value instanceof Time) {
                    statement.setTime(index, (Time) value);
                } else if (value instanceof java.util.Date) {
                    statement.setTime(index, new Time(((java.util.Date) value).getTime()));
                } else { // hh:mm:ss
                    statement.setTime(index, Time.valueOf(value.toString()));
                    // statement.setString(index, value.toString());
                }
            }
        }
    }

    /* protected */ void setTimeParameter(final Ruby runtime, final Connection connection,
                                          final PreparedStatement statement, final int index, final int type,
                                          final IRubyObject value) throws SQLException {
        if (value.isNil()) statement.setNull(index, Types.TIME);
        else {
            // setTeradataTimestampParameter(runtime, connection, statement, index, type, value);
            if (value instanceof RubyTime) {
                final RubyTime timeValue = (RubyTime) value;
                final java.util.Date dateValue = timeValue.getJavaDate();

                Time time = new Time(dateValue.getTime());
                Calendar calendar = Calendar.getInstance();
                calendar.setTime(dateValue);
                statement.setTime(index, time, calendar);
            } else {
                final String stringValue = value.convertToString().toString();
                final Time time = Time.valueOf(stringValue);
                statement.setTime(index, time, Calendar.getInstance());
            }
        }
    }

    /* protected */ void setDateParameter(final Ruby runtime, final Connection connection,
                                          final PreparedStatement statement, final int index, final int type,
                                          final Object value) throws SQLException {
        if (value instanceof IRubyObject) {
            setDateParameter(runtime, connection, statement, index, type, (IRubyObject) value);
        } else {
            if (value == null) statement.setNull(index, Types.DATE);
            else {
                if (value instanceof Date) {
                    statement.setDate(index, (Date) value);
                } else if (value instanceof java.util.Date) {
                    statement.setDate(index, new Date(((java.util.Date) value).getTime()));
                } else { // yyyy-[m]m-[d]d
                    statement.setDate(index, Date.valueOf(value.toString()));
                    // statement.setString(index, value.toString());
                }
            }
        }
    }

    /* protected */ void setDateParameter(final Ruby runtime, final Connection connection,
                                          final PreparedStatement statement, final int index, final int type,
                                          final IRubyObject value) throws SQLException {
        if (value.isNil()) statement.setNull(index, Types.DATE);
        else {
            // setTeradataTimestampParameter(runtime, connection, statement, index, type, value);
            if (value instanceof RubyTime) {
                final RubyTime timeValue = (RubyTime) value;
                final java.util.Date dateValue = timeValue.getJavaDate();

                Date date = new Date(dateValue.getTime());
                Calendar calendar = Calendar.getInstance();
                calendar.setTime(dateValue);
                statement.setDate(index, date, calendar);
            } else {
                final String stringValue = value.convertToString().toString();
                final Date date = Date.valueOf(stringValue);
                statement.setDate(index, date, Calendar.getInstance());
            }
        }
    }

    /* protected */ void setTeradataBooleanParameter(final Ruby runtime, final Connection connection,
                                                     final PreparedStatement statement, final int index, final int type,
                                                     final Object value) throws SQLException {
        if (value instanceof IRubyObject) {
            setTeradataBooleanParameter(runtime, connection, statement, index, type, (IRubyObject) value);
        } else {
            if (value == null) statement.setNull(index, Types.BOOLEAN);
            else {
                statement.setBoolean(index, ((Boolean) value).booleanValue());
            }
        }
    }

    /* protected */ void setTeradataBooleanParameter(final Ruby runtime, final Connection connection,
                                                     final PreparedStatement statement, final int index, final int type,
                                                     final IRubyObject value) throws SQLException {
        if (value.isNil()) statement.setNull(index, Types.BOOLEAN);
        else {
            statement.setBoolean(index, value.isTrue());
        }
    }

    /* protected */ void setTeradataStringParameter(final Ruby runtime, final Connection connection,
                                                    final PreparedStatement statement, final int index, final int type,
                                                    final Object value) throws SQLException {
        if (value instanceof IRubyObject) {
            setTeradataStringParameter(runtime, connection, statement, index, type, (IRubyObject) value);
        } else {
            if (value == null) statement.setNull(index, Types.VARCHAR);
            else {
                statement.setString(index, value.toString());
            }
        }
    }

    /* protected */ void setTeradataStringParameter(final Ruby runtime, final Connection connection,
                                                    final PreparedStatement statement, final int index, final int type,
                                                    final IRubyObject value) throws SQLException {
        if (value.isNil()) statement.setNull(index, Types.VARCHAR);
        else {
            statement.setString(index, value.convertToString().toString());
        }
    }

    /* protected */ void setTeradataArrayParameter(final Ruby runtime, final Connection connection,
                                                   final PreparedStatement statement, final int index, final int type,
                                                   final Object value) throws SQLException {
        if (value instanceof IRubyObject) {
            setTeradataArrayParameter(runtime, connection, statement, index, type, (IRubyObject) value);
        } else {
            if (value == null) statement.setNull(index, Types.ARRAY);
            else {
                // TODO get array element type name ?!
                Array array = connection.createArrayOf(null, (Object[]) value);
                statement.setArray(index, array);
            }
        }
    }

    /* protected */ void setTeradataArrayParameter(final Ruby runtime, final Connection connection,
                                                   final PreparedStatement statement, final int index, final int type,
                                                   final IRubyObject value) throws SQLException {
        if (value.isNil()) statement.setNull(index, Types.ARRAY);
        else {
            // TODO get array element type name ?!
            Array array = connection.createArrayOf(null, ((RubyArray) value).toArray());
            statement.setArray(index, array);
        }
    }

    /* protected */ void setTeradataXmlParameter(final Ruby runtime, final Connection connection,
                                                 final PreparedStatement statement, final int index, final int type,
                                                 final Object value) throws SQLException {
        if (value instanceof IRubyObject) {
            setTeradataXmlParameter(runtime, connection, statement, index, type, (IRubyObject) value);
        } else {
            if (value == null) statement.setNull(index, Types.SQLXML);
            else {
                SQLXML xml = connection.createSQLXML();
                xml.setString(value.toString());
                statement.setSQLXML(index, xml);
            }
        }
    }

    /* protected */ void setTeradataXmlParameter(final Ruby runtime, final Connection connection,
                                                 final PreparedStatement statement, final int index, final int type,
                                                 final IRubyObject value) throws SQLException {
        if (value.isNil()) statement.setNull(index, Types.SQLXML);
        else {
            SQLXML xml = connection.createSQLXML();
            xml.setString(value.convertToString().toString());
            statement.setSQLXML(index, xml);
        }
    }

    /* protected */ void setTeradataBlobParameter(final Ruby runtime, final Connection connection,
                                                  final PreparedStatement statement, final int index, final int type,
                                                  final Object value) throws SQLException {
        if (value instanceof IRubyObject) {
            setTeradataBlobParameter(runtime, connection, statement, index, type, (IRubyObject) value);
        } else {
            if (value == null) statement.setNull(index, Types.BLOB);
            else {
                statement.setBlob(index, (InputStream) value);
            }
        }
    }

    /* protected */ void setTeradataBlobParameter(final Ruby runtime, final Connection connection,
                                                  final PreparedStatement statement, final int index, final int type,
                                                  final IRubyObject value) throws SQLException {
        if (value.isNil()) statement.setNull(index, Types.BLOB);
        else {
            if (value instanceof RubyString) {
                statement.setBlob(index, new ByteArrayInputStream(((RubyString) value).getBytes()));
            } else { // assume IO/File
                statement.setBlob(index, ((RubyIO) value).getInStream());
            }
        }
    }

    /* protected */ void setTeradataClobParameter(final Ruby runtime, final Connection connection,
                                                  final PreparedStatement statement, final int index, final int type,
                                                  final Object value) throws SQLException {
        if (value instanceof IRubyObject) {
            setTeradataClobParameter(runtime, connection, statement, index, type, (IRubyObject) value);
        } else {
            if (value == null) statement.setNull(index, Types.CLOB);
            else {
                statement.setClob(index, (Reader) value);
            }
        }
    }

    /* protected */ void setTeradataClobParameter(final Ruby runtime, final Connection connection,
                                                  final PreparedStatement statement, final int index, final int type,
                                                  final IRubyObject value) throws SQLException {
        if (value.isNil()) statement.setNull(index, Types.CLOB);
        else {
            if (value instanceof RubyString) {
                statement.setClob(index, new StringReader(((RubyString) value).decodeString()));
            } else { // assume IO/File
                statement.setClob(index, new InputStreamReader(((RubyIO) value).getInStream()));
            }
        }
    }

    /* protected */ void setTeradataObjectParameter(final Ruby runtime, final Connection connection,
                                                    final PreparedStatement statement, final int index, final int type,
                                                    Object value) throws SQLException {
        if (value instanceof IRubyObject) {
            value = ((IRubyObject) value).toJava(Object.class);
        }
        if (value == null) statement.setNull(index, Types.JAVA_OBJECT);
        statement.setObject(index, value);
    }


}
