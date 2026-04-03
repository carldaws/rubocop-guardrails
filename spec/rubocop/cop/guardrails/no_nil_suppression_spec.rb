# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RuboCop::Cop::Guardrails::NoNilSuppression, :config do
  context 'with safe navigation' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        user&.name
        ^^^^^^^^^^ Do not use safe navigation (`&.`). [...]
      RUBY
    end

    it 'registers an offense for each link in a chain' do
      expect_offense(<<~RUBY)
        user&.account&.balance
        ^^^^^^^^^^^^^ Do not use safe navigation (`&.`). [...]
        ^^^^^^^^^^^^^^^^^^^^^^ Do not use safe navigation (`&.`). [...]
      RUBY
    end

    it 'registers an offense inside a conditional' do
      expect_offense(<<~RUBY)
        if user&.admin?
           ^^^^^^^^^^^^ Do not use safe navigation (`&.`). [...]
          do_something
        end
      RUBY
    end
  end

  context 'with try' do
    it 'registers an offense for try' do
      expect_offense(<<~RUBY)
        user.try(:name)
        ^^^^^^^^^^^^^^^ Do not use `try`. [...]
      RUBY
    end

    it 'registers an offense for try!' do
      expect_offense(<<~RUBY)
        user.try!(:name)
        ^^^^^^^^^^^^^^^^ Do not use `try!`. [...]
      RUBY
    end
  end

  it 'does not register an offense for regular method calls' do
    expect_no_offenses(<<~RUBY)
      user.name
    RUBY
  end

  it 'does not register an offense for an explicit conditional' do
    expect_no_offenses(<<~RUBY)
      user.name if user
    RUBY
  end
end
