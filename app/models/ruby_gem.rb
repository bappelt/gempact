class RubyGem
  include Neo4j::ActiveNode

  property :name, index: :exact, constraint: :unique
  property :created_at
  property :updated_at

  has_many :out, :dependencies, model_class: RubyGem, type: 'depends_on'
  has_many :in, :dependents, model_class: RubyGem, type: 'depends_on'
end
