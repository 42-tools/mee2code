Rails.application.routes.draw do
  devise_for :users, path_names: { sign_in: 'login', sign_out: 'logout' },
                     controllers: { sessions: 'users/sessions', omniauth_callbacks: 'users/omniauth_callbacks' }

  get 'users/histories', to: 'users#histories'

  root 'clusters#index'

  constraints format: /json/ do
    get 'campus/:campus_id/clusters', to: 'campus#clusters', as: 'clusters_campus', defaults: { format: 'json' }
    get 'campus/:campus_id/clusters/users', to: 'campus#clusters_users', as: 'users_clusters_campus', defaults: { format: 'json' }
  end
end
