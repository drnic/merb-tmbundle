require 'rubygems'
require 'rake'
require 'rake/testtask'

APP_VERSION="1.0.0"
APP_NAME='Merb.tmbundle'
APP_ROOT=File.dirname(__FILE__)

RUBY_APP='ruby'

desc "TMBundle Test Task"
task :default => [ :test ]
Rake::TestTask.new { |t|
  t.libs << "test"
  t.pattern = APP_ROOT + '/Support/test/test_*.rb'
  t.verbose = true
  t.warning = false
}
Dir[APP_ROOT + '/Support/tasks/**/*.rake'].each { |file| load file }
