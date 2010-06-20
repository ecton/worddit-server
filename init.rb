ROOT_DIR = File.expand_path(File.dirname(__FILE__)) unless defined? ROOT_DIR

require "rubygems"

begin
  require "vendor/dependencies-0.0.7/lib/dependencies"
rescue LoadError
  require "dependencies"
end

require "monk/glue"
require "couchrest"
require "json"
require "active_support"

class Main < Monk::Glue
  set :app_file, __FILE__
  use Rack::Session::Cookie
  
  set :haml, { :format => :html5 }
end

# Connect to couchdb.
@entities = []
couchdb_url = settings(:couchdb)[:url]
WORDDITDB = CouchRest.database!(couchdb_url)

# Load all application files.
Dir[root_path("app/**/*.rb")].each do |file|
  require file
end

Main.run! if Main.run?
