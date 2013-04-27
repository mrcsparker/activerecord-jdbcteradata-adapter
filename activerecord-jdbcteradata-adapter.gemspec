Gem::Specification.new do |s|
  s.name        = "activerecord-jdbcteradata-adapter"
  s.version     = "0.3.4"
  s.authors     = ["Chris Parker"]
  s.email       = [ "mrcsparker@gmail.com"]
  s.homepage    = "https://github.com/mrcsparker/activerecord-jdbcteradata-adapter"
  s.summary     = %q{Teradata JDBC driver for JRuby on Rails.}
  s.description = %q{Install this gem and require 'teradata' with JRuby on Rails.}

  s.rubyforge_project = "activerecord-jdbcteradata-adapter"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec'
  s.add_dependency 'activerecord-jdbc-adapter'
  s.add_dependency 'activerecord'
  s.add_dependency 'jdbc-teradata'
end
