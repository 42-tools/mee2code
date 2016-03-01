Rails.application.routes.draw do
  devise_for :users, path_names: { sign_in: 'login', sign_out: 'logout' },
                     controllers: { sessions: 'users/sessions', omniauth_callbacks: 'users/omniauth_callbacks' }
  get 'cluster/:index.json', to: 'clusters#get', as: 'cluster'
  get 'users/histories', to: 'users#histories'

  root 'clusters#index'
end
