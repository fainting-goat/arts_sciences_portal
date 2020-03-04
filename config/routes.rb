Rails.application.routes.draw do
  devise_for :users, :controllers => { :registrations => "registrations" }

  unauthenticated :user do
    root to: "pages#home", as: :unauthorized_root_path
  end

  authenticated :user do
    root to: 'dashboard#index'
  end

  get 'review', to: 'dashboard#review', as: 'review'
  get 'tallyroom', to: 'tallyroom#index'

  resources :entries do
    resources :user_entries, only: [:new, :create, :index, :destroy]
    resources :scoresheets, only: [:new, :create, :show, :update, :edit, :destroy]
  end

  scope "/admin" do
    resources :users, except: :new do
      resources :judge_preferences, only: [:new, :create, :index]
    end
    resources :user_roles
    resources :categories do
      get 'scoresheet', on: :member
    end
    resources :divisions
    resources :regions
    resources :fairs do
      get 'view_schedule', on: :member, to: 'fairs#view_schedule'
      post 'schedule', on: :member, to: 'fairs#submit_schedule'
      get 'schedule', on: :member
      get 'review', on: :member
      resources :judge_assigns
    end
    resources :timeslots
    resources :criteria
    resources :criteria_types
    resources :criteria_descriptions
    resources :applicable_criteria
    resources :scoresheets, only: [:index]
    resources :scores
    resources :judge_fairs, except: [:show]
    resources :locations
    resources :peerages
  end
end
