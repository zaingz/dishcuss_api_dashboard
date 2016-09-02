Rails.application.routes.draw do

  constraints subdomain: 'api' do
    namespace 'api' , path: '/' do

      scope "user" do
        post 'signup' => 'users#create'
        delete 'signout' => 'users#signout'
        post 'restaurant/signup' => 'users#restaurant_user_create'
        post 'signin' => 'users#signin'
        get 'email/verify/:token' => 'users#verify_email'
        get 'follow/:id' => 'users#follow'
        get 'unfollow/:id' => 'users#unfollow'
        get 'followers' => 'users#followers'
        post 'reviews' => 'reviews#create_user_review'
        get 'social/:id' => 'users#social'
        post 'message/:id' => 'users#message'
        post ':type/:id' => 'users#report'
        resources :posts , except: [:new, :edit , :show]
        get 'like/:typee/:id' => 'users#likers'
        get 'dislike/:typee/:id' => 'users#dislike' 
        scope 'posts' do
          get 'likes/:id' => 'posts#likeable'
          post 'comment/new' => 'posts#comment'
          get 'comments/:id' => 'posts#showcomment'
          resources :checkins, only: [:update]
        end
        get 'referral/:referral_code' => 'referral#create'
        get 'referral' => 'referral#get_users'
        post 'claim_credit' => 'restaurants#claim_credit'
        get 'newsfeed' => 'newsfeed#index'
        get 'localfeed' => 'users#my_feeds'
      end
      resources :restaurants, except: [:new, :edit , :show]
      scope "restaurants" do
        post 'qrcode' => 'restaurants#qrcode'
        get 'featured' => 'restaurants#featuredr'
        get 'social/:id' => 'restaurants#social'
        get 'follow/:id' => 'restaurants#follow'
        get 'unfollow/:id' => 'restaurants#unfollow'
        post 'reviews' => 'reviews#create_restaurant_review'
        resources :menus, except: [:new, :edit]
        scope 'menus' do
          resources :food_items, except: [:new, :edit]
        end
        resources :rating, only: [:create]
        get 'search' => 'restaurants#search'
        get 'categories/search' => 'categories#search'
      end
      resources :reviews, except: [:new, :edit]
      post 'reviews/comment' => 'reviews#comment'
      get 'reviews/comment/:id' => 'reviews#showcomment'
      get 'restaurants/approve/:id' => 'admin#approve_restaurant' , as: 'approve_restaurant'
      get 'restaurants/feature/:id' => 'admin#feature_restaurant' , as: 'featture_restaurant'

      post 'pundit' => 'admin#create_pundit'
      post 'credit' => 'admin#create_credit_adjust'
      get 'enable_claim/:id' => 'admin#enable_claim_restaurant'

    end
  end


  devise_for :users
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

  resources :photos, except: [:new, :edit]
  
  
  #resources :posts, except: [:new, :edit]
  resources :categories, only: [:create, :index]
  #mount Knock::Engine => "/knock"
  
  
  #resources :identities, except: [:new, :edit]
  #resources :users, except: [:new, :edit]
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".



  get 'admin/restaurants' => 'admin#index'
  get 'admin/restaurant_pending' => 'admin#rest_pending'
  get 'admin/restaurant_approved' => 'admin#rest_approved'
  get 'admin/restaurant_featured' => 'admin#rest_featured'
  get 'admin/end_users' => 'admin#end_users'
  get 'admin/restaurant_owner' => 'admin#restaurant_users'
  post 'admin/pundit' => 'admin#create_pundit'
  get 'admin/pundit' => 'admin#pundit'
  get 'admin/pundit_:id' => 'admin#edit_pundit' , as: 'edit_pundit'
  put 'admin/pundit/:id' => 'admin#update_pundit' , as: 'update_pundit'
  patch 'admin/pundit/:id' => 'admin#update_pundit'
  delete 'admin/pundit/:id' => 'admin#delete_pundit' , as: 'del_pundit'
  get 'admin/reviews' => 'admin#alL_reviews'
  get 'admin/checkins' => 'admin#user_checkins'
  get 'admin/posts' => 'admin#user_posts'
  get 'admin/unfeature_:id' => 'admin#unfeature_restaurant' , as: 'unfeature_rest'
  get 'admin/feature_:id' => 'admin#feature_restaurant' , as: 'feature_restaurant_admin'
  get 'admin/unapprove_:id' => 'admin#unapprove_restaurant' , as: 'unaprove_rest'
  get 'admin/approve_:id' => 'admin#approve_restaurant' , as: 'approve_restaurant_admin'
  get 'admin/enable_claim_:id' => 'admin#enable_claim_restaurant' , as: 'enable_claim_restaurant'
  get 'admin/disapprove_claim_:id' => 'admin#disapprove_claim_restaurant' , as: 'disapprove_claim_restaurant'
  get 'admin/restaurant_:id' => 'admin#restaurant_detail' , as: 'restauarant_ad_details'
  get 'admin/credit_history' => 'admin#credit_history' , as: 'credit_history_admin'
  get 'admin/notification_:id' => 'admin#notification' , as: 'superadmin_notification'
  get 'admin/block_:id' => 'admin#end_user_block' , as: 'block_user'
  get 'admin/unblock_:id' => 'admin#end_user_unblock' , as: 'unblock_user'
  



  get 'rest_admin/restaurants' => 'restaurant_admin#index' , as: 'owner_restaurants'
  get 'rest_admin/restaurant_:id' => 'restaurant_admin#restaurant_detail' , as: 'restauarant_owner_details'
  post 'rest_admin/search' => 'restaurant_admin#check'
  put 'rest_admin/update_:id' => 'restaurant_admin#update_rest' , as: 'restaurant_update_admin'
  put 'rest_admin/cover_image_:id' => 'restaurant_admin#update_cover_image' , as: 'cover_image_update'
  post 'rest_admin/food_items' => 'restaurant_admin#add_food_item' , as: 'restaurant_add_food_admin'
  get 'rest_admin/food_items_:id' => 'restaurant_admin#food_items' , as: 'restaurant_food_items_admin'
  delete 'rest_admin/food_items_:id' => 'restaurant_admin#delete_fooditem' , as: 'restaurant_food_items_delete_admin'
  put 'rest_admin/food_items_:id' => 'restaurant_admin#update_fooditems' , as: 'restaurant_food_items_update_admin'
  get 'rest_admin/notification_:id' => 'restaurant_admin#notifications' , as: 'restaurant_admin_notification'
  get 'rest_admin/seennotification_:id' => 'restaurant_admin#seen_notification' , as: 'restaurant_admin_seen_notification'
  get 'rest_admin/message_:id' => 'restaurant_admin#messages' , as: 'restaurant_admin_message'
  post 'rest_admin/sendmessage' => 'restaurant_admin#send_message' , as: 'admin_send_messages'
  get 'rest_admin/qrcode_:id' => 'restaurant_admin#qrcode' , as: 'qrcodes_rest_admin'
  post 'rest_admin/qrcode_:id' => 'restaurant_admin#gen_qr' , as: 'qrcode_create_rest_admin'
  get 'rest_admin/qrcodedetail_:id' => 'restaurant_admin#qrdetail' , as: 'qrcodes_detail_rest_admin'
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
