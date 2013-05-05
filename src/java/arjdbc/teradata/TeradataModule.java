package arjdbc.teradata;

import org.jruby.Ruby;
import org.jruby.RubyModule;
import org.jruby.RubyObjectAdapter;
import org.jruby.anno.JRubyMethod;
import org.jruby.javasupport.JavaEmbedUtils;
import org.jruby.runtime.ThreadContext;
import org.jruby.runtime.builtin.IRubyObject;

import java.sql.SQLException;
import java.util.List;

public class TeradataModule {

    private static RubyObjectAdapter rubyApi;

    public static void load(RubyModule arJdbc) {
        RubyModule teradata = arJdbc.defineModuleUnder("Teradata");
        teradata.defineAnnotatedMethods(TeradataModule.class);
        rubyApi = JavaEmbedUtils.newObjectAdapter();
    }

    @JRubyMethod(name = "insert_batch", required = 2, rest = true)
    public static IRubyObject insert_batch(final ThreadContext context, IRubyObject recv, IRubyObject[] args) throws SQLException {

        TeradataRubyJdbcConnection conn = (TeradataRubyJdbcConnection) rubyApi.getInstanceVariable(recv, "@connection");

        final String sql = args[0].convertToString().toString();
        IRubyObject binds = args[1];

        return conn.insertBatch(context, sql, (List) binds);
    }
}
