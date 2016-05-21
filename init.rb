require "rubygems"

require "haml"
require "sass"
require "logger"
require "dm-core"
require "dm-validations"
require "dm-migrations"
require "dm-chunked_query"
require "aws/s3"
require "mini_magick"

DataMapper::Logger.new($stdout, :debug)
DataMapper.setup(:default, (ENV['HEROKU_POSTGRESQL_GOLD_URL'] || "postgres://himself:password@localhost/peonog_development"))

if not (ENV['AWS_ACCESS_KEY_ID']).blank?
  AWS::S3::Base.establish_connection!(
    :access_key_id => ENV['AWS_ACCESS_KEY_ID'],
    :secret_access_key => ENV['AWS_SECRET_ACCESS_KEY']
  )
end


