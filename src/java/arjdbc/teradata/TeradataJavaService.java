package arjdbc.teradata;

import arjdbc.jdbc.RubyJdbcConnection;
import org.jruby.Ruby;
import org.jruby.RubyClass;
import org.jruby.RubyModule;
import org.jruby.runtime.load.BasicLibraryService;

import java.io.IOException;

public class TeradataJavaService implements BasicLibraryService {

    @Override
    public boolean basicLoad(final Ruby runtime) throws IOException {
        RubyClass jdbcConnection = ((RubyModule) runtime.getModule("ActiveRecord").getConstant("ConnectionAdapters")).getClass("JdbcConnection");

        if (jdbcConnection == null) {
            jdbcConnection = RubyJdbcConnection.createJdbcConnectionClass(runtime);
        }

        TeradataRubyJdbcConnection.createTeradataJdbcConnectionClass(runtime, jdbcConnection);

        return true;
    }
}
