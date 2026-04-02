# frozen_string_literal: true

require 'spec_helper'

# The cop is scoped to app/controllers/**/*.rb via default config.
# Here we test the offense detection logic in isolation.
RSpec.describe RuboCop::Cop::Guardrails::ControllerInstanceVariables, :config do
  let(:cop_config) { { 'Max' => 1 } }

  it 'does not register an offense for a single ivar' do
    expect_no_offenses(<<~RUBY)
      class PostsController < ApplicationController
        def show
          @card = Card.find(params[:id])
        end
      end
    RUBY
  end

  it 'registers an offense for too many ivars' do
    expect_offense(<<~RUBY)
      class PostsController < ApplicationController
        def show
            ^^^^ Too many instance variables in action (3/1). Let the view navigate from a single object.
          @card = Card.find(params[:id])
          @comments = @card.comments
          @related = @card.related_cards
        end
      end
    RUBY
  end

  it 'does not register an offense for private methods' do
    expect_no_offenses(<<~RUBY)
      class PostsController < ApplicationController
        private

        def set_card
          @card = Card.find(params[:id])
          @board = @card.board
        end
      end
    RUBY
  end

  it 'does not register an offense for inline private methods' do
    expect_no_offenses(<<~RUBY)
      class PostsController < ApplicationController
        private def set_card
          @card = Card.find(params[:id])
          @board = @card.board
        end
      end
    RUBY
  end

  it 'does not register an offense for empty actions' do
    expect_no_offenses(<<~RUBY)
      class PostsController < ApplicationController
        def index
        end
      end
    RUBY
  end

  it 'counts ivars inside conditionals' do
    expect_offense(<<~RUBY)
      class PostsController < ApplicationController
        def show
            ^^^^ Too many instance variables in action (2/1). Let the view navigate from a single object.
          @card = Card.find(params[:id])
          if @card.published?
            @comments = @card.comments
          end
        end
      end
    RUBY
  end
end
