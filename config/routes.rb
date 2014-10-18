Rails.application.routes.draw do
  get 'gems' => 'ruby_gems#index', as: 'ruby_gems'
  get 'gems/:name' => 'ruby_gems#show', as: 'ruby_gem'
end
