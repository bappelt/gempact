Rails.application.routes.draw do
  root to: 'ruby_gems#index'

  get 'gems' => 'ruby_gems#index', as: 'ruby_gems'
  get 'gems/:name' => 'ruby_gems#show', as: 'ruby_gem'

  get 'datatables/gems/:ruby_gem/dependents' => 'datatables#dependents'
  get 'datatables/gems/:ruby_gem/transitive_dependents' => 'datatables#transitive_dependents'
end
