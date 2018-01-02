# encoding: utf-8

Rails.application.routes.draw do
  resources :password_resets

  match "dot/:sha256.png", to: "dot#simple", as: "render_dot", via: :get
  match "preview", to: "latex#complex", as: "render_preview", via: :post

  root 'main#overview'

  get 'main/overview'
  match "hitme", to: "main#hitme", as: "main_hitme", via: :get
  match "help", to: "main#help", as: "main_help", via: :get
  match "feedback", to: "main#feedback", as: "feedback", via: :get
  match "feedback_send", to: "main#feedback_send", as: "feedback_send", via: :post

  resources :sessions, only: [:new, :create, :destroy]

  match 'signup', to: 'users#new', as: "signup", via: :get
  match 'signin', to: 'sessions#new', as: "signin", via: :get
  match 'signout', to: 'sessions#destroy', as: "signout", via: :get

  match "main/questions", to: "main#questions", as: "main_question", via: :get
  match "main/single_question", to: "main#single_question", as: "main_single_question", via: :get
  match "main/multiple_question", to: "main#multiple_question", as: "main_multiple_question", via: :get
  match "random_xkcd", to: "main#random_xkcd", as: "random_xkcd", via: :get
  match "specific_xkcd/:id", to: "main#specific_xkcd", as: "specific_xkcd", via: :get

  resources :users, except: :index
  match "users/:id/enrollment", to: "users#enroll", as: "enroll_user", via: :post
  match "users/:id/starred", to: "users#starred", as: "starred", via: :get
  match "users/:id/history", to: "users#history", as: "history", via: :get
  match "questions/:id/star", to: "questions#star", as: "star_question", via: :get
  match "questions/:id/unstar", to: "questions#unstar", as: "unstar_question", via: :get
  match "questions/:id/perma", to: "questions#perma", as: "perma_question", via: :get
  match "stats/:question_id", to: "stats#new", as: "new_stat", via: :post

  match '/perf', to: 'perfs#create', via: :post

  get "admin/overview"
  scope "/admin" do
    resources :text_storage, only: :update

    match "users", to: "users#index", as: "user_index", via: :get
    match "users/:id/reviews", to: "users#reviews", as: "user_reviews", via: :get

    match "toggle_reviewer/:id", to: "users#toggle_reviewer", as: "user_toggle_reviewer", via: :put
    match "toggle_admin/:id", to: "users#toggle_admin", as: "user_toggle_admin", via: :put

    match "reviews", to: "reviews#messages", as: "reviews", via: :get
    match "reviews/need_attention", to: "reviews#need_attention", as: "need_attention_questions", via: :get
    match "reviews/filter/:filter", to: "reviews#filter", as: "review_filter",via: :get
    match "reviews/find_next/:filter/", to: "reviews#find_next", as: "review_find_next",via: :get
    #match "reviews/find_next/:filter/:next", to: "reviews#find_next", as: "review_find_next",via: :get

    resources :questions do
      resources :answers
      resources :hints
      match "toggle_release", to: "questions#toggle_release", as: "toggle_release", via: :put
      match "overwrite_reviews", to: "questions#overwrite_reviews", as: "overwrite_reviews", via: :put
      match "review", to: "reviews#review", as: "review", via: :get
      match "review", to: "reviews#save", as: "review_save", via: :post # new reviews
      match "copy", to: "questions#copy", as: "copy", via: :get
      match "copy_to", to: "questions#copy_to", as: "copy_to", via: :post
      get "list_cat/:category_id", to: "questions#list_cat", on: :collection, as: "list_cat"
      get "select", to: "questions#select", on: :collection, as: "select"
      get :search, on: :collection
    end

    match "single_parent_select", to: "questions#single_parent_select", as: "single_parent_select", via: :get

    resources :categories do
      get "index_details/:category_ids", to: "categories#index_details", on: :collection, as: "index_details"
    end
    match "categories/:id/release", to: "categories#release", as: "release_category", via: :get

    match "suspicious_assocations", to: "categories#suspicious_associations", as: "suspicious_associations", via: :get
    match "categories_listmove", to: "categories#listmove", as: "categories_listmove", via: :get
    match "categories_move", to: "categories#move", as: "categories_move", via: :get
    match "categories_listactivate", to: "categories#listactivate", as: "categories_listactivate", via: :get
    match "categories_listdeactivate", to: "categories#listdeactivate", as: "categories_listdeactivate", via: :get
    match "categories_activate", to: "categories#activate", as: "categories_activate", via: :get
    match "categories_deactivate", to: "categories#deactivate", as: "categories_deactivate", via: :get
    match "category_report", to: "stats#category_report", as: "stat_category_report", via: :get

    match "activity_report", to: "stats#activity_report", as: "stat_activity_report", via: :get
    match "report/:enrollment_key", to: "stats#report", as: "stat_report", via: :get

    match "tree", to: "admin#tree", as: "tree", via: :get

    match "export", to: "admin#export", as: "export", via: :get
    match "export_question/:question_id", to: "admin#export_question", as: "export_question", via: :get
  end

  # api
  namespace :api do
    namespace :v1 do
      resources :questions, only: [:show]
    end
  end
end
