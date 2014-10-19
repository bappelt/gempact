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
      retries = 3
      begin
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
        dependency_gem_names = dependencies.collect { |gem| gem['name'] }
        dependency_gem_names.each do |dependency_name|
          puts "|--- finding dependency #{dependency_name}"
          dependency = RubyGem.find_by(name: dependency_name)
          dependency = RubyGem.create!(name: dependency_name) if dependency.nil?
          new_gem.dependencies << dependency unless new_gem.dependencies.include?(dependency)
        end

        new_gem.save!
      rescue StandardError => e
        puts $!
        retries -= 1
        if retries > 0
          puts "retrying #{gem_name}"
          retry
        else
          raise e
        end
      end

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

  desc 'This task calculates gem dependency totals'
  task :rank => :environment do
    puts "updating gem counts..."
    RubyGem.all.each do |rgem|
      direct_count = RubyGem.where(name: rgem.name).query_as(:r).match("r<-[depends_on*1]-(b:RubyGem)").return(:b).to_a.size
      indirect_count = RubyGem.where(name: rgem.name).query_as(:r).match("r<-[depends_on*1..]-(b:RubyGem)").return(:b).to_a.size
      rgem.direct_dependents = direct_count
      rgem.total_dependents = indirect_count
      rgem.save!
      print '.'
      STDOUT.flush
    end
  end

  desc 'This task checks for duplicate dependency listings'
  task :remove_dupes => :environment do
    puts 'removing duplicate dependencies'
    RubyGem.all.each do |rgem|
      deps = rgem.dependencies.to_a.uniq
      dup_cnt = rgem.dependencies.size - deps.size
      if dup_cnt > 0
        puts "removing #{dup_cnt} duplicates from #{rgem.name}"
        rgem.dependencies = deps
        rgem.save!
      else
        print '.'
        STDOUT.flush
      end
    end
  end

  def format_number(number)
    number.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse
  end

end
