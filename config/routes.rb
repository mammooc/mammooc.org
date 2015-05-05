# -*- encoding : utf-8 -*-
Rails.application.routes.draw do
  get 'api_connection/index'
  get 'api_connection/send_request'
  post 'api_connection/send_user_request'
  get 'api_connection/update_user'
  get 'api_connection/update_all_users'

  devise_for :users, skip: [:registrations], controllers: {registrations: 'users/registrations',
                                                           sessions: 'users/sessions',
                                                           passwords: 'users/passwords'}
  as :user do
    get '/users/cancel' => 'users/registrations#cancel', :as => 'cancel_user_registration'
    post '/users' => 'users/registrations#create', :as => 'user_registration'
    get '/users/sign_up' => 'users/registrations#new', :as => 'new_user_registration'
    patch '/users' => 'users/registrations#update'
    put '/users' => 'users/registrations#update'
    delete '/users' => 'users/registrations#destroy'
  end

  resources :user_assignments

  resources :course_assignments

  resources :evaluations

  resources :bookmarks

  resources :progresses

  resources :approvals

  resources :course_requests

  resources :certificates

  resources :completions

  resources :user_groups

  resources :comments

  resources :recommendations, except: [:edit, :show, :update, :destroy]

  resources :statistics

  resources :groups

  resources :course_results

  resources :mooc_providers

  resources :emails

  resources :users, except: [:new, :create, :index]

  get 'dashboard/dashboard'

  get 'home/index'
  get 'about' => 'static_pages#about'
  get 'dashboard' => 'dashboard#dashboard'

  # Groups
  post 'groups/:id/invite_members' => 'groups#invite_group_members'
  post 'groups/:id/add_administrator' => 'groups#add_administrator'
  post 'groups/:id/demote_administrator' => 'groups#demote_administrator'
  post 'groups/:id/remove_group_member' => 'groups#remove_group_member'
  post 'groups/:id/condition_for_changing_member_status' => 'groups#condition_for_changing_member_status'
  post 'groups/:id/leave' => 'groups#leave'
  get 'groups/join/:token' => 'groups#join'
  get 'groups/:id/members' => 'groups#members'
  get 'groups/:id/recommendations' => 'groups#recommendations'
  get 'groups/:id/statistics' => 'groups#statistics'
  get 'groups/:id/all_members_to_administrators' => 'groups#all_members_to_administrators'
  get 'groups/:id/synchronize_courses' => 'groups#synchronize_courses'

  get 'impressum' => 'static_pages#impressum'
  get 'recommendations/:id/delete_user_from_recommendation' => 'recommendations#delete_user_from_recommendation'
  get 'recommendations/:id/delete_group_recommendation' => 'recommendations#delete_group_recommendation'
  root to: 'home#index'

  # Courses
  get 'courses' => 'courses#index'
  get 'courses/index'
  get 'courses/:id' => 'courses#show', as: 'course'
  get 'courses/:id/enroll_course' => 'courses#enroll_course'
  get 'courses/:id/unenroll_course' => 'courses#unenroll_course'

  # Users
  get 'users/:id/synchronize_courses' => 'users#synchronize_courses'
  get 'users/:id/settings' => 'users#settings'
  get 'users/:id/account_settings' => 'users#account_settings'
  get 'users/:id/mooc_provider_settings' => 'users#mooc_provider_settings'
  get 'users/:id/set_mooc_provider_connection' => 'users#set_mooc_provider_connection'
  get 'users/:id/revoke_mooc_provider_connection' => 'users#revoke_mooc_provider_connection'

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
