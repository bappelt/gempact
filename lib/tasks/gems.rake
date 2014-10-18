require 'open-uri'
require 'zlib'
require 'rest_client'

namespace :gems do
  desc 'This task will load all rubygem data'
  task :load => :environment do
    puts 'Loading gems...'
    compressed = open("http://rubygems.org/specs.4.8.gz")
    inflated = Zlib::GzipReader.new(compressed).read
    gem_names = Marshal.load(inflated).collect { |entry| entry[0] }
    gem_names.uniq!

    failures = []
    start_index = ENV.fetch('start', 0).to_i
    gem_names.each_with_index do |gem_name, index|
      next if index < start_index
      new_gem = RubyGem.find_by(name: gem_name)
      new_gem = RubyGem.create!(name: gem_name) unless new_gem.present?
      puts "processing gem #{format_number(index)} of #{format_number(gem_names.count)}: #{gem_name}"

      gem_url = "https://rubygems.org/api/v1/gems/#{gem_name}.json"

      begin
        gem_spec_str = RestClient.get(gem_url)
      rescue RestClient::ResourceNotFound => error
        puts "ERROR: Problem GET-ing: #{gem_url} (full trace will appear at the end)"
        failures << error
        next
      end

      gem_spec = JSON.parse(gem_spec_str)
      dependencies = gem_spec['dependencies']['runtime']
      dependency_gem_names = dependencies.collect { |gem| gem['name']}
      dependency_gem_names.each do |dependency_name|
        puts "|--- finding dependency #{dependency_name}"
        dependency = RubyGem.find_by(name: dependency_name)
        dependency = RubyGem.create!(name: dependency_name) if dependency.nil?
        new_gem.dependencies << dependency unless new_gem.dependencies.include?(dependency)
      end

      new_gem.save!
    end

    puts "\n==============================="
    puts "Done!\n"

    if failures.any?
      puts "There were #{failures.count} errors:"
      puts failures
    else
      puts "Success!  There were no errors"
    end

    puts "==============================="
  end

  def format_number(number)
    number.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse
  end
end
