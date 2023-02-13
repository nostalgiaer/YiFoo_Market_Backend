Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  root 'users#index'
  get 'test', to: 'posts#test'
  get 'admin', to: 'users#create_admin'

  # scope "api-dev" do
    scope :api do
      post :register, to: 'users#register', as: :user_register
      post :login, to: 'users#login', as: :user_login
      get :follows, to: 'users#follows', as: :user_follow_show

      scope :user do
        post 'password/:id', to: 'users#modify_password', as: :user_modify_password
        post 'email/:id', to: 'users#modify_email', as: :user_modify_email
        post 'username/:id', to: 'users#modify_username', as: :user_modify_username
        get ':id', to: 'users#show', as: :user_info_show
        post 'avatar/:id', to: 'users#avatar', as: :user_modify_avatar
      end

      scope :notification do
        get :deal, to: 'notifications#show_purchase'
        get :reply, to: 'replies#show'
        get :hasEamil, to: "notifications#unchecked"
        get 'purchase/:id', to: 'notifications#open'
        get 'deal/:id', to: 'notifications#confirm'
        get 'reply/:id', to: 'replies#open'
      end

      get :complaint, to: 'complaints#show', as: :complaints_show
      delete :complaint, to: 'complaints#solve', as: :complaint_solve
      get :order, to: 'indents#show'

      get :tag, to: 'tags#show', as: :tag_show
      post :tag, to: 'tags#create', as: :tag_create
      delete :tag, to: 'tags#delete', as: :tag_delete

      get :broadcast, to: 'broadcasts#show'
      put 'broadcast/:broadcastId', to: 'broadcasts#modify'
      delete 'broadcast/:broadcastId', to: 'broadcasts#delete'
      post :broadcast, to: 'broadcasts#create'

      get :cart, to: 'trolleys#show'
      delete :cart, to: 'trolleys#delete'
      post :cart, to: 'trolleys#purchase'
      put :cart, to: 'trolleys#modify'

      scope :post do
        root 'posts#show', as: :post_show
        get ':postId', to: 'posts#open', as: :post_open
        put ':postId', to: 'posts#modify', as: :post_modify_content
        delete ':postId', to: 'posts#close', as: :post_delete

        post 'search', to: 'posts#search'

        # tag #
        get ':postId/tag', to: 'posts#acquire_available_tags', as: :post_available_tags
        post ':postId/tag/add', to: 'posts#add_tag', as: :post_add_tag
        delete ':postId/tag/delete', to: 'posts#delete_tag', as: :post_delete_tag

        # complaint #
        post ':postId/complain', to: 'posts#complaint', as: :post_complaint

        post ':postId/comment/:commentId/likes', to: 'comments#like'

        scope :buy do
          put :new, to: 'posts#create_buy', as: :buy_post_create
          post "new/img", to: "posts#update_buy_post_image", as: :but_post_image_upload
        end

        scope :sell do
          put :new, to: 'posts#create_sell', as: :sell_post_create

          post 'new/img', to: 'posts#update_commodity_images', as: :sell_commodity_image_upload

          put ':postId/commodity', to: 'posts#modify_remain', as: :commodity_modify_remain
          get ':postId/commodity', to: 'posts#commodities', as: :commodities
          delete ':postId/commodity', to: 'posts#delete_commodity', as: :commodity_delete
          post ':postId/commodity/new', to: 'posts#create_commodity', as: :commodity_create
          post ':postId/commodity/buy', to: 'posts#purchase', as: :commodity_purchase
          post ':postId/cart', to: 'posts#trolley'

        end

        post ':postId/follow', to: 'posts#follow', as: :post_follow
        delete ':postId/follow', to: 'posts#non_follow', as: :post_non_follow

        get ':postId/comment', to: 'comments#show', as: :comment_show
        post ':postId/comment', to: 'comments#create_post_comment', as: :post_comment_create
        post ':postId/comment/:commentId', to: 'comments#create_inner_comment', as: :inner_comment_create
        put ':postId/comment/:commentId', to: 'comments#create_inner_comment_reply', as: :comment_reply_create
        delete ':postId/comment/:commentId', to: 'comments#delete', as: :comment_destroy
      end

    # end
  end

end
