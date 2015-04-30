class Importer
  @queue = :importer_queue

  def self.perform(gem_name)
    puts "The environment is: #{ENV.inspect}"
    RubyGem.pull_spec_and_create(gem_name)
  end

end