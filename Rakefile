require 'bundler'

def install_tasks(opts = nil)
  dir = caller.find{|c| /Rakefile:/}[/^(.*?)\/Rakefile:/, 1]
  h = Bundler::GemHelper.new(dir, opts && opts[:name])
  h.install
  h
end
helper = install_tasks
spec = helper.gemspec

require 'rake/clean'
CLEAN.include 'test/reports','lib/**/*.jar','*.log', 'pkg'

task :git_local_check do
  sh "git diff --no-ext-diff --ignore-submodules --quiet --exit-code" do |ok, _|
    raise "working directory is unclean" if !ok
    sh "git diff-index --cached --quiet --ignore-submodules HEAD --" do |ok, _|
      raise "git index is unclean" if !ok
    end
  end
end
task :build => [:java_compile, :git_local_check]

require 'rake/testtask'

# overriding the default rake tests loader
class Rake::TestTask
  def rake_loader
    'test/my-minitest-loader.rb'
  end
end

Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  ar_jdbc = ENV['AR_JDBC'] ||
    (begin
       gem 'activerecord-jdbc-adapter'
       Gem.loaded_specs['activerecord-jdbc-adapter'].full_gem_path
     rescue
       raise "Please install activerecord-jdbc-adapter to run tests."
     end)
  test.libs << File.join(ar_jdbc, 'test')
  test.pattern = 'test/**/*test*.rb'
  test.verbose = true
end

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "#{spec.name} #{spec.version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
