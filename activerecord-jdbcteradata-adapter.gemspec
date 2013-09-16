Gem::Specification.new do |s|
  s.name        = 'activerecord-jdbcteradata-adapter'
  s.version     = '0.5.1'
  s.authors     = ['Chris Parker']
  s.email       = %w(mrcsparker@gmail.com)
  s.homepage    = 'https://github.com/mrcsparker/activerecord-jdbcteradata-adapter'
  s.summary     = %q{Teradata JDBC driver for JRuby on Rails.}
  s.description = %q{Install this gem and require 'teradata' with JRuby on Rails.}
  s.license = 'MIT'

  s.rubyforge_project = 'activerecord-jdbcteradata-adapter'

  s.files = %w[
    Gemfile
    Gemfile.lock
    LICENSE.txt
    README.md
    activerecord-jdbcteradata-adapter.gemspec
    lib/active_record/connection_adapters/jdbcteradata_adapter.rb
    lib/active_record/connection_adapters/teradata_adapter.rb
    lib/activerecord-jdbcteradata-adapter.rb
    lib/arel/engines/sql/compilers/teradata_compiler.rb
    lib/arel/visitors/teradata.rb
    lib/arjdbc/discover.rb
    lib/arjdbc/teradata/adapter.rb
    lib/arjdbc/teradata/connection_methods.rb
    lib/arjdbc/teradata/teradata_java.jar
    lib/arjdbc/teradata/explain_support.rb
    lib/arjdbc/teradata.rb
  ]

  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = %w(lib)

  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec'
  s.add_dependency 'activerecord-jdbc-adapter'
  s.add_dependency 'activerecord', '<= 3.2.13'
  s.add_dependency 'jdbc-teradata'
end
