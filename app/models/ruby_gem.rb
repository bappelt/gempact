class RubyGem
  include Neo4j::ActiveNode
  include Rails.application.routes.url_helpers

  property :name, index: :exact, constraint: :unique
  property :info
  property :homepage_uri
  property :source_code_uri
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

  def create_dependencies_from_spec(gem_spec)
    dependencies = gem_spec['dependencies']['runtime']
    dependency_gem_names = dependencies.collect { |gem| gem['name'] }
    dependency_list = []
    dependency_gem_names.each do |dependency_name|
      dependency = RubyGem.find_or_create_by_name(dependency_name)
      dependency_list << dependency
    end
    self.dependencies = dependency_list
  end

  def self.find_or_create_by_name(gem_name)
    new_gem = RubyGem.find_by(name: gem_name)
    new_gem = RubyGem.create!(name: gem_name) unless new_gem.present?
    new_gem.save!
    new_gem
  end

  def self.create_or_update_from_spec(gemspec)
    gem_name = gemspec['name']
    new_gem = self.find_or_create_by_name(gem_name)
    new_gem.info = gemspec['info']
    new_gem.homepage_uri = gemspec['homepage_uri']
    new_gem.source_code_uri = gemspec['source_code_uri']
    new_gem
  end

  def self.pull_spec_and_create(gem_name)
    gem_url = "https://rubygems.org/api/v1/gems/#{gem_name}.json"
    gem_spec_str = RestClient.get(gem_url)
    gem_spec = JSON.parse(gem_spec_str)
    new_gem = RubyGem.create_or_update_from_spec(gem_spec)
    new_gem.create_dependencies_from_spec(gem_spec)
    new_gem.save!
  end

end
