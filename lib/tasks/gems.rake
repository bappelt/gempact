require 'open-uri'
require 'zlib'
require 'rest_client'

namespace :gems do

  desc "Load the gem names into the queue to be imported"
  task :queue_loading, [:limit] => :environment do |t, args|
    compressed = open("http://rubygems.org/specs.4.8.gz")
    inflated = Zlib::GzipReader.new(compressed).read
    gem_names = Marshal.load(inflated).collect { |entry| entry[0] }
    gem_names.uniq!
    gem_names = gem_names[0..args.limit.to_i-1] if args.limit
    gem_names.each { |gem_name| Resque.enqueue(Importer, gem_name) }
    puts "enqueued #{gem_names.size} gems"
  end

  desc 'This task calculates gem dependency totals'
  task :rank => :environment do
    depth = ENV.fetch('depth', RubyGem::MAX_SEARCH_DEPTH).to_i
    puts "updating gem counts using depth #{depth}..."
    unranked_count = RubyGem.where(ranked_at: nil).count
    while unranked_count > 0
      puts "#{unranked_count} unranked gems"
      r_gems = RubyGem.query_as(:rg).where('rg.ranked_at is null').limit(1000).pluck(:rg)
      r_gems.each do |rgem|
        begin
          direct_count = RubyGem.count_dependents(rgem.name)
          indirect_count = RubyGem.count_transitive_dependents(rgem.name)
          rgem.direct_dependents = direct_count
          rgem.total_dependents = indirect_count
          rgem.ranked_at = Time.now
          rgem.save!
        rescue Neo4j::Server::CypherResponse::ResponseError => e
          puts $!
          puts "unable to get indirect count for #{rgem.name}"
          indirect_count = nil
        end
        print '.'
        STDOUT.flush
      end
      unranked_count = RubyGem.where(ranked_at: nil).count
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
