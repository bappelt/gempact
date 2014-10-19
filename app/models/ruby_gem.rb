class RubyGem
  include Neo4j::ActiveNode

  property :name, index: :exact, constraint: :unique
  property :created_at
  property :updated_at
  property :ranked_at, type: Time
  property :direct_dependents
  property :total_dependents

  has_many :out, :dependencies, model_class: RubyGem, type: 'depends_on'
  has_many :in, :dependents, model_class: RubyGem, type: 'depends_on'

  MAX_SEARCH_DEPTH = 6

  def gempact_score
    return nil unless direct_dependents && total_dependents
    ((direct_dependents || 0) + (total_dependents || 0) / 1000).to_i
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
end
