# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RuboCop::Cop::Guardrails::NoGuardClauses, :config do
  let(:cop_config) { { 'MinMethodLength' => 10 } }

  context 'when the method is short' do
    it 'registers an offense for return if' do
      expect_offense(<<~RUBY)
        def something
          return if thing.nil?
          ^^^^^^^^^^^^^^^^^^^^ Avoid guard clauses. Prefer a conditional expression.
          thing.do_something
        end
      RUBY
    end

    it 'registers an offense for return unless' do
      expect_offense(<<~RUBY)
        def something
          return unless thing
          ^^^^^^^^^^^^^^^^^^^ Avoid guard clauses. Prefer a conditional expression.
          thing.do_something
        end
      RUBY
    end

    it 'registers an offense for return with a value' do
      expect_offense(<<~RUBY)
        def something
          return :default if thing.nil?
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid guard clauses. Prefer a conditional expression.
          thing.do_something
        end
      RUBY
    end

    it 'registers offenses for multiple guard clauses' do
      expect_offense(<<~RUBY)
        def something
          return if a?
          ^^^^^^^^^^^^ Avoid guard clauses. Prefer a conditional expression.
          return if b?
          ^^^^^^^^^^^^ Avoid guard clauses. Prefer a conditional expression.
          do_thing
        end
      RUBY
    end

    it 'registers an offense at exactly MinMethodLength lines' do
      expect_offense(<<~RUBY)
        def something
          return unless valid?
          ^^^^^^^^^^^^^^^^^^^^ Avoid guard clauses. Prefer a conditional expression.
          step_one
          step_two
          step_three
          step_four
          step_five
          step_six
          step_seven
        end
      RUBY
    end
  end

  context 'when the method is long' do
    it 'allows one guard clause' do
      expect_no_offenses(<<~RUBY)
        def something
          return unless valid?
          step_one
          step_two
          step_three
          step_four
          step_five
          step_six
          step_seven
          step_eight
          step_nine
        end
      RUBY
    end

    it 'registers an offense for the second guard clause' do
      expect_offense(<<~RUBY)
        def something
          return unless valid?
          return if done?
          ^^^^^^^^^^^^^^^ Avoid guard clauses. Prefer a conditional expression.
          step_one
          step_two
          step_three
          step_four
          step_five
          step_six
          step_seven
        end
      RUBY
    end
  end

  it 'does not register an offense without guard clauses' do
    expect_no_offenses(<<~RUBY)
      def something
        thing.do_something if thing
      end
    RUBY
  end

  it 'does not flag conditional returns in the middle of a method' do
    expect_no_offenses(<<~RUBY)
      def something
        prepare
        return if failed?
        execute
      end
    RUBY
  end

  it 'handles class methods' do
    expect_offense(<<~RUBY)
      def self.something
        return if thing.nil?
        ^^^^^^^^^^^^^^^^^^^^ Avoid guard clauses. Prefer a conditional expression.
        thing.do_something
      end
    RUBY
  end

  it 'registers an offense for a guard clause preceded by an assignment' do
    expect_offense(<<~RUBY)
      def something
        result = compute
        return if result.blank?
        ^^^^^^^^^^^^^^^^^^^^^^^ Avoid guard clauses. Prefer a conditional expression.
        result.do_something
      end
    RUBY
  end

  it 'sees through multiple assignments to find a guard clause' do
    expect_offense(<<~RUBY)
      def something
        a = compute_a
        b = compute_b(a)
        return if b.nil?
        ^^^^^^^^^^^^^^^^ Avoid guard clauses. Prefer a conditional expression.
        process(b)
      end
    RUBY
  end

  it 'does not flag a guard after a non-assignment statement' do
    expect_no_offenses(<<~RUBY)
      def something
        prepare
        return if failed?
        execute
      end
    RUBY
  end

  it 'does not register an offense for empty methods' do
    expect_no_offenses(<<~RUBY)
      def something
      end
    RUBY
  end
end
