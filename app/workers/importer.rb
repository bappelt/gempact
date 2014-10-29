class Importer
  @queue = :importer_queue

  def self.perform(gem_name)
    retries = 3
    begin
      new_gem = RubyGem.find_by(name: gem_name)
      new_gem = RubyGem.create!(name: gem_name) unless new_gem.present?
      puts "processing gem  #{gem_name}"

      gem_url = "https://rubygems.org/api/v1/gems/#{gem_name}.json"

      gem_spec_str = RestClient.get(gem_url)

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
end