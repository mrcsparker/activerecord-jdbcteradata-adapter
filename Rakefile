require 'rake/clean'
CLEAN.include 'lib/arjdbc/teradata/teradata_java.jar','classes'

require 'bundler/gem_helper'
Bundler::GemHelper.install_tasks

require 'bundler/setup'

task :default => :jar

#ugh, bundler doesn't use tasks, so gotta hook up to both tasks.
task :build => :jar
task :install => :jar

task :jar => [:clean] do
  ruby 'java_compile.rb'
end
