require 'resque'
require 'resque-honeybadger'
require 'resque/failure/multiple'
require 'resque/failure/redis'

Resque.logger = Rails.logger

if ENV["REDISCLOUD_URL"]
  uri = URI.parse ENV["REDISCLOUD_URL"]
  Resque.redis = Redis.new host: uri.host, port: uri.port, password: uri.password
end

Resque::Failure::Multiple.classes = [Resque::Failure::Redis, Resque::Failure::Honeybadger]
Resque::Failure.backend = Resque::Failure::Multiple

