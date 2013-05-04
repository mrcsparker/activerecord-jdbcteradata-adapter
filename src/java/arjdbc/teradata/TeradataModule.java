package arjdbc.teradata;

import java.sql.SQLException;

import arjdbc.jdbc.RubyJdbcConnection;

import org.jruby.Ruby;
import org.jruby.RubyBoolean;
import org.jruby.RubyModule;
import org.jruby.RubyObjectAdapter;
import org.jruby.RubyString;
import org.jruby.anno.JRubyMethod;
import org.jruby.javasupport.JavaEmbedUtils;
import org.jruby.runtime.ThreadContext;
import org.jruby.runtime.builtin.IRubyObject;
import org.jruby.util.ByteList;

public class TeradataModule {

  private static RubyObjectAdapter rubyApi;

  public static void load(RubyModule arJdbc) {
    RubyModule teradata = arJdbc.defineModuleUnder("Teradata");
    teradata.defineAnnotatedMethods(TeradataModule.class);
    rubyApi = JavaEmbedUtils.newObjectAdapter();
  }

  @JRubyMethod(name = "insert_batch", required = 2, rest = false)
  public IRubyObject insert_batch(final ThreadContext context, IRubyObject recv, final IRubyObject[] args) throws SQLException {
    Ruby runtime = recv.getRuntime();
    TeradataRubyJdbcConnection conn = (TeradataRubyJdbcConnection) rubyApi.getInstanceVariable(recv, "@connection");
    return conn.insert_batch(context, recv, args);
  } 
}
