# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RuboCop::Cop::Guardrails::RestfulRoutes, :config do
  context 'when using resources' do
    it 'allows resources' do
      expect_no_offenses(<<~RUBY)
        Rails.application.routes.draw do
          resources :posts
        end
      RUBY
    end

    it 'allows resource' do
      expect_no_offenses(<<~RUBY)
        Rails.application.routes.draw do
          resource :session
        end
      RUBY
    end

    it 'allows resources with only/except' do
      expect_no_offenses(<<~RUBY)
        Rails.application.routes.draw do
          resources :posts, only: [:index, :show]
        end
      RUBY
    end

    it 'allows nested resources' do
      expect_no_offenses(<<~RUBY)
        Rails.application.routes.draw do
          resources :posts do
            resources :comments
          end
        end
      RUBY
    end
  end

  context 'when using structural route methods' do
    it 'allows root' do
      expect_no_offenses(<<~RUBY)
        Rails.application.routes.draw do
          root 'home#index'
        end
      RUBY
    end

    it 'allows namespace' do
      expect_no_offenses(<<~RUBY)
        Rails.application.routes.draw do
          namespace :admin do
            resources :posts
          end
        end
      RUBY
    end

    it 'allows scope' do
      expect_no_offenses(<<~RUBY)
        Rails.application.routes.draw do
          scope '/api' do
            resources :posts
          end
        end
      RUBY
    end

    it 'allows constraints' do
      expect_no_offenses(<<~RUBY)
        Rails.application.routes.draw do
          constraints(subdomain: 'api') do
            resources :posts
          end
        end
      RUBY
    end

    it 'allows mount' do
      expect_no_offenses(<<~RUBY)
        Rails.application.routes.draw do
          mount Sidekiq::Web => '/sidekiq'
        end
      RUBY
    end

    it 'allows concern and concerns' do
      expect_no_offenses(<<~RUBY)
        Rails.application.routes.draw do
          concern :commentable do
            resources :comments
          end

          resources :posts, concerns: :commentable
        end
      RUBY
    end

    it 'allows draw' do
      expect_no_offenses(<<~RUBY)
        Rails.application.routes.draw do
          draw :api
        end
      RUBY
    end

    it 'allows direct and resolve' do
      expect_no_offenses(<<~RUBY)
        Rails.application.routes.draw do
          direct(:homepage) { "https://example.com" }
          resolve("Basket") { [:basket] }
        end
      RUBY
    end

    it 'allows defaults' do
      expect_no_offenses(<<~RUBY)
        Rails.application.routes.draw do
          defaults format: :json do
            resources :posts
          end
        end
      RUBY
    end
  end

  context 'when using bare HTTP verb routes' do
    it 'registers an offense for get' do
      expect_offense(<<~RUBY)
        Rails.application.routes.draw do
          get '/health', to: 'health#show'
          ^^^ Use `resources` or `resource` instead of bare HTTP verb routes.
        end
      RUBY
    end

    it 'registers an offense for post' do
      expect_offense(<<~RUBY)
        Rails.application.routes.draw do
          post '/posts/:id/publish', to: 'posts#publish'
          ^^^^ Use `resources` or `resource` instead of bare HTTP verb routes.
        end
      RUBY
    end

    it 'registers an offense for put' do
      expect_offense(<<~RUBY)
        Rails.application.routes.draw do
          put '/posts/:id', to: 'posts#update'
          ^^^ Use `resources` or `resource` instead of bare HTTP verb routes.
        end
      RUBY
    end

    it 'registers an offense for patch' do
      expect_offense(<<~RUBY)
        Rails.application.routes.draw do
          patch '/posts/:id', to: 'posts#update'
          ^^^^^ Use `resources` or `resource` instead of bare HTTP verb routes.
        end
      RUBY
    end

    it 'registers an offense for delete' do
      expect_offense(<<~RUBY)
        Rails.application.routes.draw do
          delete '/posts/:id', to: 'posts#destroy'
          ^^^^^^ Use `resources` or `resource` instead of bare HTTP verb routes.
        end
      RUBY
    end

    it 'registers an offense for match' do
      expect_offense(<<~RUBY)
        Rails.application.routes.draw do
          match '/posts/:id', to: 'posts#show', via: :get
          ^^^^^ Use `resources` or `resource` instead of bare HTTP verb routes.
        end
      RUBY
    end
  end

  context 'when using member and collection blocks' do
    it 'registers an offense for a member block' do
      expect_offense(<<~RUBY)
        Rails.application.routes.draw do
          resources :posts do
            member do
            ^^^^^^ Use a new `resources` instead of `member` routes.
              get :publish
            end
          end
        end
      RUBY
    end

    it 'registers an offense for a collection block' do
      expect_offense(<<~RUBY)
        Rails.application.routes.draw do
          resources :posts do
            collection do
            ^^^^^^^^^^ Use a new `resources` instead of `collection` routes.
              get :search
            end
          end
        end
      RUBY
    end

    it 'registers an offense for inline member route' do
      expect_offense(<<~RUBY)
        Rails.application.routes.draw do
          resources :posts do
            get :publish, on: :member
            ^^^ Use `resources` or `resource` instead of bare HTTP verb routes.
          end
        end
      RUBY
    end

    it 'registers an offense for inline collection route' do
      expect_offense(<<~RUBY)
        Rails.application.routes.draw do
          resources :posts do
            get :search, on: :collection
            ^^^ Use `resources` or `resource` instead of bare HTTP verb routes.
          end
        end
      RUBY
    end
  end
end
