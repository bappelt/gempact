class RubyGem
  include Neo4j::ActiveNode
  include Rails.application.routes.url_helpers

  property :name, index: :exact, constraint: :unique
  property :created_at
  property :updated_at
  property :ranked_at, type: Time
  property :direct_dependents
  property :total_dependents

  has_many :out, :dependencies, model_class: RubyGem, type: 'depends_on'
  has_many :in, :dependents, model_class: RubyGem, type: 'depends_on'

  MAX_SEARCH_DEPTH = 5

  def gempact_score
    total_dependents
  end

  def badge_url
    "#{root_url}gems/#{name}/badge"
  end

  def self.count_dependents(parent_gem, search: nil)
    search_expr = search.blank? ? '' : "WHERE dependent.name =~ '.*#{search}.*' "

    Neo4j::Session.query(
      "MATCH (g:RubyGem { name: '#{parent_gem}' }) " +
        "<-[:depends_on]-(dependent:RubyGem) " +
        "#{search_expr} RETURN COUNT(DISTINCT(dependent)) " +
        "AS total_count").first.total_count
  end

  def self.count_transitive_dependents(parent_gem, search: nil)
    search_expr = search.blank? ? '' : "WHERE dependent.name =~ '.*#{search}.*' "

    Neo4j::Session.query(
      "MATCH (g:RubyGem { name: '#{parent_gem}' }) " +
        "<-[:depends_on*1..#{MAX_SEARCH_DEPTH}]-(dependent:RubyGem) " +
        "#{search_expr} RETURN COUNT(DISTINCT(dependent)) " +
        "AS total_count").first.total_count
  end

  def self.find_dependents(ruby_gem, search: nil, offset: 0, limit: 100)
    safe_offset = [offset.to_i, 0].max
    safe_limit = [limit.to_i, 100].min

    search_expr = search.blank? ? '' : "WHERE dependent.name =~ '.*#{search}.*' "

    Neo4j::Session.query(
      "MATCH (g:RubyGem { name: '#{ruby_gem}'}) " +
        "<-[:depends_on]-(dependent:RubyGem) " +
        "#{search_expr} RETURN DISTINCT(dependent) AS dependent " +
        "SKIP #{safe_offset} LIMIT #{safe_limit}")
  end

  def self.find_transitive_dependents(ruby_gem, search: nil, offset: 0, limit: 100)
    safe_offset = [offset.to_i, 0].max
    safe_limit = [limit.to_i, 100].min

    search_expr = search.blank? ? '' : "WHERE dependent.name =~ '.*#{search}.*' "

    Neo4j::Session.query(
      "MATCH (g:RubyGem { name: '#{ruby_gem}' }) " +
        "<-[:depends_on*1..#{MAX_SEARCH_DEPTH}]-(dependent:RubyGem) " +
        "#{search_expr} RETURN DISTINCT(dependent) AS dependent " +
        "SKIP #{safe_offset} LIMIT #{safe_limit}")
  end

  def rank
    direct_count = RubyGem.count_dependents(name)
    indirect_count = RubyGem.count_transitive_dependents(name)
    self.direct_dependents = direct_count
    self.total_dependents = indirect_count
    self.ranked_at = Time.now
    self.save!
  end

  def self.pull_spec_and_create(gem_name)
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
      dependency_list = []
      dependency_gem_names.each do |dependency_name|
        puts "|--- finding dependency #{dependency_name}"
        dependency = RubyGem.find_by(name: dependency_name)
        dependency = RubyGem.create!(name: dependency_name) if dependency.nil?
        dependency_list << dependency
      end
      new_gem.dependencies = dependency_list
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
