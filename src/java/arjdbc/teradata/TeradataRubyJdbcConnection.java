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
import org.jruby.util.ByteList;

public class TeradataRubyJdbcConnection extends RubyJdbcConnection {

    protected TeradataRubyJdbcConnection(Ruby runtime, RubyClass metaClass) {
        super(runtime, metaClass);
    }

    @Override
    protected boolean databaseSupportsSchemas() {
        return false;
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

    @Override
    protected IRubyObject jdbcToRuby(Ruby runtime, int column, int type, ResultSet resultSet)
        throws SQLException {
        if ( Types.BLOB == type || Types.BINARY == type || Types.VARBINARY == type || Types.LONGVARBINARY == type ) {
            if ( resultSet.wasNull() ) return runtime.getNil();
            try {
                return streamToRuby(runtime, resultSet, column);
            }
            catch (IOException e) {
                throw new SQLException(e.getMessage(), e);
            }
        }
        else {
            return super.jdbcToRuby(runtime, column, type, resultSet);
        }
    }

    protected IRubyObject streamToRuby(
        final Ruby runtime, final ResultSet resultSet, final int column)
        throws SQLException, IOException {
        final byte[] bytes = resultSet.getBytes(column);
        if ( resultSet.wasNull() ) return runtime.getNil();
        return runtime.newString( new ByteList(bytes, false) );
    }

}
