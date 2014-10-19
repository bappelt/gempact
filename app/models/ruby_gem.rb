class RubyGem
  include Neo4j::ActiveNode

  property :name, index: :exact, constraint: :unique
  property :created_at
  property :updated_at
  property :direct_dependents
  property :total_dependents

  has_many :out, :dependencies, model_class: RubyGem, type: 'depends_on'
  has_many :in, :dependents, model_class: RubyGem, type: 'depends_on'

  def transitive_dependents
    query_as(:g).match('g<-[depends_on*1..]-(object:RubyGem)').return(:object)
  end

  def to_s
    name
  end
end
