require 'resque'
require 'resque-honeybadger'
require 'resque/failure/multiple'
require 'resque/failure/redis'

if ENV["REDISCLOUD_URL"]
  uri = URI.parse ENV["REDISCLOUD_URL"]
  Resque.redis = Redis.new host: uri.host, port: uri.port, password: uri.password
end

Resque::Failure::Honeybadger.configure do |config|
  config.api_key = ENV['HONEYBADGER_API_KEY']
end

Resque::Failure::Multiple.classes = [Resque::Failure::Redis, Resque::Failure::Honeybadger]
Resque::Failure.backend = Resque::Failure::Multiple

