require 'open-uri'
require 'zlib'
require 'rest_client'

def pull_gem_list(limit=nil)
  compressed = open("http://rubygems.org/specs.4.8.gz")
  inflated = Zlib::GzipReader.new(compressed).read
  gem_names = Marshal.load(inflated).collect { |entry| entry[0] }
  gem_names.uniq!
  gem_names = gem_names[0..limit.to_i-1] if limit
  gem_names
end

namespace :gems do

  desc "Load the gem names into the queue to be imported"
  task :queue_loading, [:limit] => :environment do |t, args|
    gem_names = pull_gem_list(args.limit)
    gem_names.each { |gem_name| Resque.enqueue(Importer, gem_name) }
    puts "enqueued #{gem_names.size} gems"
  end

  desc 'This task queues ranking of all gems'
  task :queue_ranking, [:limit] => :environment do |t, args|
    gem_names = pull_gem_list(args.limit)
    gem_names.each { |gem_name| Resque.enqueue(Ranker, gem_name) }
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
