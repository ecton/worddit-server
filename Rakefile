require(File.join(File.dirname(__FILE__), 'init.rb'))

require 'rake'
Dir["#{File.dirname(__FILE__)}/tasks/*.rake"].each { |ext| load ext }

desc 'Default task: run all tests'
task :default => [:test]

task :test do
  exec "thor monk:test"
end
