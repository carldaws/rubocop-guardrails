# frozen_string_literal: true

require 'spec_helper'

# The cop is scoped to app/controllers/**/*.rb via default config.
# Here we test the offense detection logic in isolation.
RSpec.describe RuboCop::Cop::Guardrails::NoInlineAuthorization, :config do
  context 'with head' do
    it 'registers an offense for head :forbidden in a public method' do
      expect_offense(<<~RUBY)
        class PostsController < ApplicationController
          def destroy
            head :forbidden unless Current.user.can_administer?(@post)
            ^^^^^^^^^^^^^^^ Extract authorization to a `before_action` callback.
          end
        end
      RUBY
    end

    it 'registers an offense for head :unauthorized in a public method' do
      expect_offense(<<~RUBY)
        class PostsController < ApplicationController
          def show
            head :unauthorized unless authenticated?
            ^^^^^^^^^^^^^^^^^^ Extract authorization to a `before_action` callback.
          end
        end
      RUBY
    end

    it 'does not register an offense for head with other status codes' do
      expect_no_offenses(<<~RUBY)
        class PostsController < ApplicationController
          def create
            head :no_content
          end
        end
      RUBY
    end
  end

  context 'with render' do
    it 'registers an offense for render status: :forbidden' do
      expect_offense(<<~RUBY)
        class PostsController < ApplicationController
          def show
            render status: :forbidden
            ^^^^^^^^^^^^^^^^^^^^^^^^^ Extract authorization to a `before_action` callback.
          end
        end
      RUBY
    end

    it 'registers an offense for render with template and status: :unauthorized' do
      expect_offense(<<~RUBY)
        class PostsController < ApplicationController
          def show
            render "errors/unauthorized", status: :unauthorized
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Extract authorization to a `before_action` callback.
          end
        end
      RUBY
    end

    it 'does not register an offense for render with other statuses' do
      expect_no_offenses(<<~RUBY)
        class PostsController < ApplicationController
          def create
            render :new, status: :unprocessable_entity
          end
        end
      RUBY
    end
  end

  context 'with visibility' do
    it 'does not register an offense in a private method' do
      expect_no_offenses(<<~RUBY)
        class PostsController < ApplicationController
          private

          def ensure_can_administer
            head :forbidden unless Current.user.admin?
          end
        end
      RUBY
    end

    it 'does not register an offense in a protected method' do
      expect_no_offenses(<<~RUBY)
        class PostsController < ApplicationController
          protected

          def ensure_can_administer
            head :forbidden unless Current.user.admin?
          end
        end
      RUBY
    end

    it 'does not register an offense for an inline private method' do
      expect_no_offenses(<<~RUBY)
        class PostsController < ApplicationController
          private def ensure_can_administer
            head :forbidden unless Current.user.admin?
          end
        end
      RUBY
    end
  end

  it 'does not register an offense outside a method' do
    expect_no_offenses(<<~RUBY)
      head :forbidden
    RUBY
  end
end
