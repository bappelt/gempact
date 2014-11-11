class GemHistory

  include Mongoid::Document

  field :gem_name, type: String
  field :year, type: Integer
  field :direct_dependent_counts, type: Array, default: []
  field :total_dependent_counts, type: Array, default: []

end