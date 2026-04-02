# frozen_string_literal: true

require 'spec_helper'

# The cop is scoped to app/controllers/**/*.rb via default config.
# Here we test the offense detection logic in isolation.
RSpec.describe RuboCop::Cop::Guardrails::ControllerTransaction, :config do
  it 'registers an offense for a transaction block' do
    expect_offense(<<~RUBY)
      def create
        ActiveRecord::Base.transaction do
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid transactions in controllers. Move business logic to a model method.
          @card.create_closure!(user: Current.user)
          @card.track_event(:closed)
        end
      end
    RUBY
  end

  it 'registers an offense for a transaction on an instance' do
    expect_offense(<<~RUBY)
      def create
        @card.transaction do
        ^^^^^^^^^^^^^^^^^ Avoid transactions in controllers. Move business logic to a model method.
          @card.create_closure!(user: Current.user)
          @card.track_event(:closed)
        end
      end
    RUBY
  end

  it 'registers an offense for a bare transaction call' do
    expect_offense(<<~RUBY)
      def create
        transaction do
        ^^^^^^^^^^^ Avoid transactions in controllers. Move business logic to a model method.
          do_something
        end
      end
    RUBY
  end

  it 'does not register an offense without a transaction' do
    expect_no_offenses(<<~RUBY)
      def create
        @card.close
      end
    RUBY
  end
end
