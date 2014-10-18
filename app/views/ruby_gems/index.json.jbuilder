json.array!(@ruby_gems) do |ruby_gem|
  json.extract! ruby_gem, :id
  json.url ruby_gem_url(ruby_gem, format: :json)
end
