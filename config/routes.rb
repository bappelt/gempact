Rails.application.routes.draw do
  root to: 'ruby_gems#index'

  get 'gems' => 'ruby_gems#index', as: 'ruby_gems'
  get 'gems/:name' => 'ruby_gems#show', as: 'ruby_gem'

  get 'gems/:name/dependents/count' => 'ruby_gems#dependents_count',
    as: 'ruby_gem_dependents_count'

  get 'gems/:name/transitive_dependents/count' => 'ruby_gems#transitive_dependents_count',
    as: 'ruby_gem_transitive_dependents_count'

  get 'datatables/gems/ranked' => 'datatables#ranked'

  get 'datatables/gems/:ruby_gem/dependents' => 'datatables#dependents'
  get 'datatables/gems/:ruby_gem/transitive_dependents' => 'datatables#transitive_dependents'
end
