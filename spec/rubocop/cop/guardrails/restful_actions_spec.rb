# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RuboCop::Cop::Guardrails::RestfulActions, :config do
  it 'allows all seven RESTful actions' do
    expect_no_offenses(<<~RUBY)
      class PostsController < ApplicationController
        def index; end
        def show; end
        def new; end
        def create; end
        def edit; end
        def update; end
        def destroy; end
      end
    RUBY
  end

  it 'registers an offense for a non-RESTful action' do
    expect_offense(<<~RUBY)
      class PostsController < ApplicationController
        def publish
            ^^^^^^^ Non-RESTful action `publish`. Add a new resource to represent this action.
        end
      end
    RUBY
  end

  it 'does not register an offense for private methods' do
    expect_no_offenses(<<~RUBY)
      class PostsController < ApplicationController
        def index; end

        private

        def set_post; end
      end
    RUBY
  end

  it 'does not register an offense for protected methods' do
    expect_no_offenses(<<~RUBY)
      class PostsController < ApplicationController
        def index; end

        protected

        def set_post; end
      end
    RUBY
  end

  it 'does not register an offense for inline private methods' do
    expect_no_offenses(<<~RUBY)
      class PostsController < ApplicationController
        def index; end

        private def set_post; end
      end
    RUBY
  end

  it 'does not register an offense for methods in modules' do
    expect_no_offenses(<<~RUBY)
      module Publishable
        def publish; end
      end
    RUBY
  end

  it 'respects visibility reset with public' do
    expect_offense(<<~RUBY)
      class PostsController < ApplicationController
        private

        def set_post; end

        public

        def publish
            ^^^^^^^ Non-RESTful action `publish`. Add a new resource to represent this action.
        end
      end
    RUBY
  end
end
