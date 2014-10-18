require 'open-uri'
require 'zlib'
require 'rest_client'

desc 'This task will load all rubygem data'
task :load_gems do
  puts 'loading gems...'
  compressed = open("http://rubygems.org/specs.4.8.gz")
  inflated = Zlib::GzipReader.new(compressed).read
  gem_names = Marshal.load(inflated).collect { |entry| entry[0] }
  gem_names.uniq!
  gem_count = gem_names.size
  index = 1
  gem_names.each do |gem_name|
    puts "processing gem #{index} of #{gem_count}: #{gem_name}"
    gem_spec_str = RestClient.get "https://rubygems.org/api/v1/gems/#{gem_name}.json"
    gem_spec = JSON.parse(gem_spec_str)
    dependencies = gem_spec['dependencies']['runtime']
    dependency_gem_names = dependencies.collect { |gem| gem['name']}
    puts "#{gem_name} : #{dependency_gem_names.join(',')}"
    index += 1
  end
end