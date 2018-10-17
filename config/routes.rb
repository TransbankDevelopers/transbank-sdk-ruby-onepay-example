Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html


  root to: 'transaction#index'
  get 'transactions', to: 'transaction#index'
  post 'transactions/create', to: 'transaction#create'
  get 'transactions/commit', to: 'transaction#commit'
  get 'transactions/refund', to: 'transaction#refund'
end
