# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RuboCop::Cop::Guardrails::ExplicitConditional, :config do
  context 'with if' do
    it 'registers an offense for a bare local variable' do
      expect_offense(<<~RUBY)
        if user
           ^^^^ Use a predicate method (e.g. `present?`) instead of a bare truthiness check.
          do_something
        end
      RUBY
    end

    it 'registers an offense for a bare instance variable' do
      expect_offense(<<~RUBY)
        if @user
           ^^^^^ Use a predicate method (e.g. `present?`) instead of a bare truthiness check.
          do_something
        end
      RUBY
    end

    it 'registers an offense for a bare method call' do
      expect_offense(<<~RUBY)
        if current_user
           ^^^^^^^^^^^^ Use a predicate method (e.g. `present?`) instead of a bare truthiness check.
          do_something
        end
      RUBY
    end

    it 'registers an offense for modifier if' do
      expect_offense(<<~RUBY)
        do_something if user
                        ^^^^ Use a predicate method (e.g. `present?`) instead of a bare truthiness check.
      RUBY
    end
  end

  context 'with unless' do
    it 'registers an offense for a bare local variable' do
      expect_offense(<<~RUBY)
        unless user
               ^^^^ Use `nil?` instead of a bare truthiness check.
          do_something
        end
      RUBY
    end

    it 'registers an offense for a bare instance variable' do
      expect_offense(<<~RUBY)
        unless @user
               ^^^^^ Use `nil?` instead of a bare truthiness check.
          do_something
        end
      RUBY
    end

    it 'registers an offense for modifier unless' do
      expect_offense(<<~RUBY)
        do_something unless record
                            ^^^^^^ Use `nil?` instead of a bare truthiness check.
      RUBY
    end
  end

  context 'when the condition is a chained method call' do
    it 'registers an offense for attribute access' do
      expect_offense(<<~RUBY)
        if user.name
           ^^^^^^^^^ Use a predicate method (e.g. `present?`) instead of a bare truthiness check.
          do_something
        end
      RUBY
    end

    it 'registers an offense for a class accessor' do
      expect_offense(<<~RUBY)
        Current.api_key.touch(:last_used_at) if Current.api_key
                                                ^^^^^^^^^^^^^^^ Use a predicate method (e.g. `present?`) instead of a bare truthiness check.
      RUBY
    end

    it 'registers an offense for hash access' do
      expect_offense(<<~RUBY)
        do_something if cookies.signed[:session_id]
                        ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use a predicate method (e.g. `present?`) instead of a bare truthiness check.
      RUBY
    end

    it 'registers an offense for ENV lookup' do
      expect_offense(<<~RUBY)
        do_something if ENV["PIDFILE"]
                        ^^^^^^^^^^^^^^ Use a predicate method (e.g. `present?`) instead of a bare truthiness check.
      RUBY
    end
  end

  context 'when the condition returns a boolean' do
    it 'allows save' do
      expect_no_offenses(<<~RUBY)
        if @project.save
          do_something
        end
      RUBY
    end

    it 'allows update' do
      expect_no_offenses(<<~RUBY)
        if @user.update(params)
          do_something
        end
      RUBY
    end

    it 'allows destroy' do
      expect_no_offenses(<<~RUBY)
        if @record.destroy
          do_something
        end
      RUBY
    end

    it 'allows delete' do
      expect_no_offenses(<<~RUBY)
        if @record.delete
          do_something
        end
      RUBY
    end
  end

  context 'when the condition is already explicit' do
    it 'allows predicate methods' do
      expect_no_offenses(<<~RUBY)
        if user.present?
          do_something
        end
      RUBY
    end

    it 'allows nil check' do
      expect_no_offenses(<<~RUBY)
        unless user.nil?
          do_something
        end
      RUBY
    end

    it 'allows blank check' do
      expect_no_offenses(<<~RUBY)
        if user.blank?
          do_something
        end
      RUBY
    end

    it 'allows comparison operators' do
      expect_no_offenses(<<~RUBY)
        if count > 0
          do_something
        end
      RUBY
    end

    it 'allows equality checks' do
      expect_no_offenses(<<~RUBY)
        if user == nil
          do_something
        end
      RUBY
    end

    it 'allows negation' do
      expect_no_offenses(<<~RUBY)
        if !user
          do_something
        end
      RUBY
    end
  end

  context 'when the condition is compound' do
    it 'allows && expressions' do
      expect_no_offenses(<<~RUBY)
        if user && user.admin?
          do_something
        end
      RUBY
    end

    it 'allows || expressions' do
      expect_no_offenses(<<~RUBY)
        if user || fallback
          do_something
        end
      RUBY
    end
  end

  it 'allows ternary expressions' do
    expect_no_offenses(<<~RUBY)
      user ? "yes" : "no"
    RUBY
  end

  it 'allows boolean literals' do
    expect_no_offenses(<<~RUBY)
      if true
        do_something
      end
    RUBY
  end

  it 'flags elsif with a bare condition' do
    expect_offense(<<~RUBY)
      if user.present?
        one
      elsif account
            ^^^^^^^ Use a predicate method (e.g. `present?`) instead of a bare truthiness check.
        two
      end
    RUBY
  end
end
