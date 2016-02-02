source 'https://rubygems.org'

ruby '2.1.7'

gem 'rails', '4.1.5'
gem 'sass-rails', '~> 4.0.3'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.0.0'

gem 'jquery-rails'
gem 'jbuilder', '~> 2.0'
gem 'rest-client'
gem 'resque', '~> 1.25.2'

gem 'neo4j', '~>4.1.5'
gem 'neo4j-core'
gem 'mongoid', '~> 4.0.0'

gem 'foundation-rails', '5.4.5.0'

gem 'zeroclipboard-rails'

gem 'chartkick'

group :development, :test do
  gem 'pry-byebug'
  gem 'webmock', require: false
  gem 'factory_girl_rails'
end


group :doc do
  gem 'sdoc', '~> 0.4.0'
end

group :production, :staging do
  gem 'rails_12factor'
  gem 'unicorn'
  gem 'honeybadger', '~> 2.0'
  gem 'resque-honeybadger'
end
