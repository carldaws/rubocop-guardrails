# frozen_string_literal: true

require 'spec_helper'

# The cop is scoped to test/**/*.rb via default config.
# Here we test the offense detection logic in isolation.
RSpec.describe RuboCop::Cop::Guardrails::NoTestStrings, :config do
  context 'with assertions' do
    it 'registers an offense for assert_equal with a string' do
      expect_offense(<<~RUBY)
        assert_equal "Published", card.status
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid hardcoded strings in assertions. Assert against the source value, an i18n key, or a predicate.
      RUBY
    end

    it 'registers an offense for assert_includes with a string' do
      expect_offense(<<~RUBY)
        assert_includes response.body, "Welcome back"
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid hardcoded strings in assertions. Assert against the source value, an i18n key, or a predicate.
      RUBY
    end

    it 'registers an offense for assert_match with a string' do
      expect_offense(<<~RUBY)
        assert_match "Welcome", response.body
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid hardcoded strings in assertions. Assert against the source value, an i18n key, or a predicate.
      RUBY
    end

    it 'registers an offense for assert_flash with a string' do
      expect_offense(<<~RUBY)
        assert_flash "Card published"
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid hardcoded strings in assertions. Assert against the source value, an i18n key, or a predicate.
      RUBY
    end

    it 'registers an offense for refute_equal with a string' do
      expect_offense(<<~RUBY)
        refute_equal "Draft", card.status
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid hardcoded strings in assertions. Assert against the source value, an i18n key, or a predicate.
      RUBY
    end

    it 'registers an offense for interpolated strings' do
      expect_offense(<<~'RUBY')
        assert_equal "Hello #{name}", greeting
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid hardcoded strings in assertions. Assert against the source value, an i18n key, or a predicate.
      RUBY
    end

    it 'does not register an offense for assertions without strings' do
      expect_no_offenses(<<~RUBY)
        assert_equal :published, card.status
        assert card.published?
        assert_predicate card, :published?
        assert_respond_to card, :close
      RUBY
    end
  end

  context 'with find_by' do
    it 'registers an offense with a string value' do
      expect_offense(<<~RUBY)
        Card.find_by(title: "Logo Design")
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid finding records by string values. Use fixtures instead.
      RUBY
    end

    it 'does not register an offense with symbol values' do
      expect_no_offenses(<<~RUBY)
        Card.find_by(status: :published)
      RUBY
    end

    it 'does not register an offense with variable values' do
      expect_no_offenses(<<~RUBY)
        Card.find_by(id: card_id)
      RUBY
    end
  end

  context 'with where' do
    it 'registers an offense with a string value' do
      expect_offense(<<~RUBY)
        Card.where(title: "Logo Design")
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid finding records by string values. Use fixtures instead.
      RUBY
    end

    it 'does not register an offense with symbol values' do
      expect_no_offenses(<<~RUBY)
        Card.where(status: :published)
      RUBY
    end
  end

  context 'with excluded assertions' do
    it 'does not register an offense for assert_difference' do
      expect_no_offenses(<<~RUBY)
        assert_difference "Card.count" do
          post cards_path, params: { card: { title: "New" } }
        end
      RUBY
    end

    it 'does not register an offense for assert_no_difference' do
      expect_no_offenses(<<~RUBY)
        assert_no_difference "Card.count" do
          post cards_path
        end
      RUBY
    end

    it 'does not register an offense for assert_changes' do
      expect_no_offenses(<<~RUBY)
        assert_changes "card.status" do
          card.publish
        end
      RUBY
    end

    it 'does not register an offense for assert_select' do
      expect_no_offenses(<<~RUBY)
        assert_select "h1.title"
      RUBY
    end

    it 'does not register an offense for assert_routing' do
      expect_no_offenses(<<~RUBY)
        assert_routing "/cards/1", controller: "cards", action: "show", id: "1"
      RUBY
    end

    it 'does not register an offense for assert_template' do
      expect_no_offenses(<<~RUBY)
        assert_template "cards/show"
      RUBY
    end

    it 'does not register an offense for assert_path_exists' do
      expect_no_offenses(<<~RUBY)
        assert_path_exists "tmp/exports/cards.csv"
      RUBY
    end
  end

  it 'does not register an offense for unrelated methods' do
    expect_no_offenses(<<~RUBY)
      assert card.published?
      card.update!(title: "New Title")
    RUBY
  end
end
