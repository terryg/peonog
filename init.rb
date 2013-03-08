ROOT_DIR = File.expand_path(File.dirname(__FILE__)) unless defined? ROOT_DIR

require "rubygems"

begin
  require File.expand_path("vendor/dependencies/lib/dependencies", File.dirname(__FILE__))
rescue LoadError
  require "dependencies"
end

require "monk/glue"
require "ohm"
require "haml"
require "sass"
require "logger"
require "dm-core"
require "dm-validations"
require "dm-migrations"
require "dm-chunked_query"
require "aws/s3"

class Main < Monk::Glue
  set :app_file, __FILE__
  use Rack::Session::Cookie
end

# Connect to redis database.
Ohm.connect(monk_settings(:redis))

# Load all application files.
Dir[root_path("app/**/*.rb")].each do |file|
  require file
end

if defined? Encoding
  Encoding.default_external = Encoding::UTF_8
end

DataMapper.setup(:default, (ENV['HEROKU_POSTGRESQL_GOLD_URL'] || "sqlite:///#{Dir.pwd}/db/development.sqlite3"))
DataMapper.auto_upgrade!

AWS::S3::Base.establish_connection!(
  :access_key_id => ENV['AWS_ACCESS_KEY_ID'],
  :secret_access_key => ENV['AWS_SECRET_ACCESS_KEY']
)

Main.run! if Main.run?
