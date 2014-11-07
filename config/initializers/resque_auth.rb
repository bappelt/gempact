require 'resque/server'

Resque::Server.use(Rack::Auth::Basic) do |user, password|
  password == ENV['RESQUE_WEB_HTTP_BASIC_AUTH_PASSWORD'] && user==ENV['RESQUE_WEB_HTTP_BASIC_AUTH_USER']
end