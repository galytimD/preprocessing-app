# frozen_string_literal: true
require 'sidekiq/web'

Rails.application.routes.draw do

  get 'up' => 'rails/health#show', as: :rails_health_check
  mount Sidekiq::Web => '/sidekiq'
  get "/downloads/*path", to: redirect("/downloads/%{path}")
  get 'images/coordinates', to: 'images#coordinates'
  get 'images/count_preproccessed', to: 'images#count_preproccessed'
 
  resources :datasets, except: %i[new create edit] do
    collection do
      get :download
      post :upload
      post :preprocessing
    end
    resources :images, only: [:destroy] do
      collection do
        delete 'batch_destroy'
      end
    end
  end
end
