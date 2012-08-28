Refinery::Core::Engine.routes.draw do
  namespace :mailchimp, :path => '' do
    # Admin routes
    namespace :admin, :path => 'refinery' do
      resources :campaigns do
        member do
          get :send_options
          post :send_test
          post :send_now
          post :schedule
          post :unschedule
          post :posts
        end
        collection do
          get :update_positions
        end
      end
      resources :posts_campaigns, :except => [:show] do
        member do
          get :send_options
          post :send_test
          post :send_now
          post :schedule
          post :unschedule
          post :posts
          get :add_post
        end
        collection do
          get :pause
          get :resume
        end
      end
    end

    # Frontend routes
    resource :subscriptions, :only => :create
  end
end
