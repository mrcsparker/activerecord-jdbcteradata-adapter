package arjdbc.teradata;

import java.io.IOException;

import org.jruby.Ruby;
import org.jruby.RubyClass;
import org.jruby.RubyModule;
import org.jruby.RubyObjectAdapter;
import org.jruby.javasupport.JavaEmbedUtils;
import org.jruby.runtime.load.BasicLibraryService;

import arjdbc.jdbc.RubyJdbcConnection;

public class TeradataJavaService implements BasicLibraryService {
    private static RubyObjectAdapter rubyApi;

    public boolean basicLoad(final Ruby runtime) throws IOException {
        RubyClass jdbcConnection = RubyJdbcConnection.createJdbcConnectionClass(runtime);
        TeradataRubyJdbcConnection.createTeradataJdbcConnectionClass(runtime, jdbcConnection);
        
        RubyModule arJdbc = runtime.getOrCreateModule("ArJdbc");

        TeradataModule.load(arJdbc);

        return true;
    }
}
