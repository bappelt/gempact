require File.expand_path('../boot', __FILE__)

require "action_controller/railtie"
require "action_mailer/railtie"
require "sprockets/railtie"
require "rails/test_unit/railtie"
require 'neo4j/railtie'

Bundler.require(*Rails.groups)

module Gempact
  class Application < Rails::Application
    config.neo4j.session_type = :server_db
    config.neo4j.session_path = ENV['GRAPHENEDB_URL'] || 'http://localhost:7474'
    config.autoload_paths << Rails.root.join('lib')
    config.cache_store = :memory_store, { size: 64.megabytes }
  end
end
