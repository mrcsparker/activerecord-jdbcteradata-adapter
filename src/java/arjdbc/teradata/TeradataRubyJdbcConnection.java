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

}
