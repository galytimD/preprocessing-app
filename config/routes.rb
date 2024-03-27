# frozen_string_literal: true
require 'sidekiq/web'

Rails.application.routes.draw do
  root 'datasets#index'
  get 'up' => 'rails/health#show', as: :rails_health_check
  mount Sidekiq::Web => '/sidekiq'
  resources :datasets, except: %i[new create] do
    collection do
      get :download_datasets
    end
    member do
      get :preprocessing
      patch :update_preprocessing
    end
    resources :images, only: [] do
      collection do
        delete 'batch_destroy'
      end
    end
  end
end
