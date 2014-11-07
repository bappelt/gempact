ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'webmock/minitest'

class ActiveSupport::TestCase

  def stub_gemspec_request(gemname, filename=gemname)
      data = File.open("test/data/#{filename}.json").read

      stub_request(:get, "https://rubygems.org/api/v1/gems/#{gemname}.json").
        with(:headers => {'Accept' => '*/*; q=0.5, application/xml', 'Accept-Encoding' => 'gzip, deflate', 'User-Agent' => 'Ruby'}).
        to_return(:status => 200, :body => data, :headers => {})
    end

    def create_gem_with_dependencies(gem_name, dependency_names)
      av = RubyGem.create(name: gem_name)
      dependency_names.each do |dep|
        gem = RubyGem.create(name: dep)
        av.dependencies << gem
      end
    end

end
