# frozen_string_literal: true

Rails.application.routes.draw do
  match '400', via: :all, to: 'errors#bad_request'
  match '404', via: :all, to: 'errors#not_found'
  match '406', via: :all, to: 'errors#not_acceptable'
  match '422', via: :all, to: 'errors#unprocessable'
  match '500', via: :all, to: 'errors#internal_server_error'
  match '502', via: :all, to: 'errors#bad_gateway'
  match '503', via: :all, to: 'errors#service_unavailable'

  namespace :admin do
    get '/', to: 'dashboard#index', as: 'root'
    post "reviews/update_review", to: "reviews#update_review", as: :update_review

    resources :users
    resources :posts
    resources :reviews
    resources :interests
  end

  namespace :reporter do
    get '/', to: 'dashboard#index', as: 'root'
    resources :users, only: [:update], controller: "dashboard", as: 'kpis'

    get '/landing_page_metrics', to: 'metrics#landing_page_metrics'
    get '/feature_engagement_metrics', to: 'metrics#feature_engagement_metrics'
    get '/gamification_metrics', to: 'metrics#gamification_metrics'
    get '/user_growth_metrics', to: 'metrics#user_growth_metrics'
  end

  namespace :subscriber do
    get '/', to: 'dashboard#index', as: 'root'

    resources :users, only: [:update], controller: "dashboard", as: 'kpis'

    get "/pomodoro", to: "pomodoro#show", as: :pomodoro
    get "/notifications", to: "notifications#index", as: :notifications
    get '/task_history', to: 'task_history#index', as: :task_history

    patch "/subscriber/individual_tasks/:id/complete", to: "individual_tasks#complete", as: :complete_individual_task
    patch "/subscriber/shared_tasks/:id/complete", to: "shared_tasks#complete", as: :complete_shared_task
    patch "/subscriber/shared_tasks/:id/assign_users", to: "shared_tasks#assign_users", as: :assign_users_shared_task

    patch "/notifications/:id/mark", to: "notifications#mark", as: :mark
    patch "/subscriber/notifications/:id/accept_invitation", to: "notifications#accept_invitation", as: :accept_invitation
    patch "/subscriber/notifications/:id/decline_invitation", to: "notifications#decline_invitation", as: :decline_invitation

    # resources :notifications
    resource :project, only: [:show]
    resources :individual_tasks, only: [:show, :new, :create, :update, :destroy]
    resources :items, controller: "item_shop", only: [:index, :show]
    resources :user_items, controller: "item_shop", only: [:create]
    resources :plants, only: [:update]

    resource :project, only: [:show]
    resources :individual_tasks, only: [:show, :new, :create, :update, :destroy]

    get "shared_projects", to: "shared_projects#index", as: :shared_projects
    get "/shared_project/:id/leaderboard", to: "shared_projects#leaderboard", as: :shared_project_leaderboard
    get "/shared_project/:id/settings", to: "shared_projects#team_member_edit", as: :shared_project_settings

    patch "/shared_project/:id/settings_update", to: "shared_projects#update_team_member", as: :shared_project_update_team_member
    patch "/shared_project/:id/leave_project", to: "shared_projects#remove_team_member", as: :shared_project_remove_team_member

    resources :shared_projects, only: [:show, :new, :create, :edit, :update, :destroy]
    resources :shared_tasks, only: [:show, :new, :create, :update, :destroy]

    post "plants/:id/water", to: "plants#water", as: :plant_water
    # resources :shared_projects
    # get "shopping", to: "shopping#index"

    post "ai_taskbreakdown/generate", to: "ai_messages#create", as: :ai_taskbreakdown_generate
    post 'ai_taskbreakdown/fallback', to: 'ai_messages#fallback', as: :ai_taskbreakdown_fallback

  end

  devise_for :users,
    path: "",
    path_names: {
      sign_in: "login",
      sign_out: "logout",
      password: "password"
    },

    controllers: {
      sessions: "users/sessions",
      registrations: "users/registrations",
      passwords: "users/passwords"
    }

  mount Ahoy::Engine => "/ahoy", as: :my_ahoy

  root 'pages#home'
  resources :posts, only: [:create]
  resources :interests, only: [:create]
  resources :reviews, only: [:new, :create] do
    member do
      post :upvote
      post :downvote
    end
  end
end
