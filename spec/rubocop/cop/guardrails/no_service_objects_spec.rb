# frozen_string_literal: true

require 'spec_helper'

# The cop is scoped to app/services/**/*.rb via default config.
# Here we test the offense detection logic in isolation.
RSpec.describe RuboCop::Cop::Guardrails::NoServiceObjects, :config do
  it 'registers an offense for a class definition' do
    expect_offense(<<~RUBY)
      class PostPublisher
            ^^^^^^^^^^^^^ Avoid service objects. This logic belongs in your models.
      end
    RUBY
  end

  it 'registers an offense for a namespaced class' do
    expect_offense(<<~RUBY)
      class Posts::PublishService
            ^^^^^^^^^^^^^^^^^^^^^ Avoid service objects. This logic belongs in your models.
      end
    RUBY
  end

  it 'registers an offense for a class with a superclass' do
    expect_offense(<<~RUBY)
      class PostPublisher < ApplicationService
            ^^^^^^^^^^^^^ Avoid service objects. This logic belongs in your models.
      end
    RUBY
  end

  it 'does not register an offense for a module' do
    expect_no_offenses(<<~RUBY)
      module PostPublishing
      end
    RUBY
  end
end
