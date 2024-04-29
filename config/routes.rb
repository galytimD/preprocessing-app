# frozen_string_literal: true
require 'sidekiq/web'

Rails.application.routes.draw do
  root 'datasets#index'
  get 'up' => 'rails/health#show', as: :rails_health_check
  mount Sidekiq::Web => '/sidekiq'
  get "/downloads/*path", to: redirect("/downloads/%{path}")
  get 'images/coordinates', to: 'images#coordinates'
  resources :datasets, except: %i[new create] do
    collection do
      get :download_datasets
    end
    member do
      get :preprocessing
      patch :update_preprocessing
    end
    resources :images, only: [:destroy] do
      collection do
        delete 'batch_destroy'
      end
    end
  end
end
