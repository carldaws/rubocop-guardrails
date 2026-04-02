# frozen_string_literal: true

module RuboCop
  module Cop
    module Guardrails
      # Prevents string literals in test assertions and finders.
      #
      # Asserting on string copy or finding records by string values
      # makes tests brittle — when copy changes, unrelated tests
      # break. Use i18n keys, element IDs, predicate methods, or
      # fixtures instead.
      #
      # Flags:
      # - Any `assert_*` or `refute_*` method with a string literal
      #   argument, except those where strings are part of the API
      #   (expressions, selectors, paths, etc.)
      # - `find_by` / `where` with string literal values
      #
      # @example
      #   # bad
      #   assert_equal "Published", card.status
      #   assert_includes response.body, "Welcome back"
      #   assert_match "Success", response.body
      #   assert_flash "Card published"
      #   card = Card.find_by(title: "Logo Design")
      #
      #   # good
      #   assert card.published?
      #   assert_select "#flash-notice"
      #   assert_difference "Card.count" do ... end
      #   assert_equal I18n.t("flash.success"), flash[:notice]
      #   card = cards(:logo)
      class NoTestStrings < Base
        MSG_ASSERTION = 'Avoid hardcoded strings in assertions. Assert against the source value, an i18n key, or a predicate.'
        MSG_FINDER = 'Avoid finding records by string values. Use fixtures instead.'

        # Assertions where string arguments are part of the API
        # (Ruby expressions, CSS selectors, paths, etc.) — not copy.
        EXCLUDED_ASSERTIONS = %i[
          assert_changes
          assert_no_changes
          assert_deprecated
          assert_difference
          assert_no_difference
          assert_dom
          assert_not_dom
          assert_not_select
          assert_generates
          assert_path_exists
          assert_recognizes
          assert_routing
          assert_select
          assert_template
          refute_dom
          refute_path_exists
          refute_select
        ].to_set.freeze

        def on_send(node)
          method = node.method_name

          if flagged_assertion?(method)
            add_offense(node, message: MSG_ASSERTION) if any_string_argument?(node)
          elsif %i[find_by where].include?(method)
            add_offense(node, message: MSG_FINDER) if any_string_hash_value?(node)
          end
        end

        private

        def flagged_assertion?(method)
          assertion_method?(method) && !EXCLUDED_ASSERTIONS.include?(method)
        end

        def assertion_method?(method)
          method_str = method.to_s
          method_str.start_with?('assert_') || method_str.start_with?('refute_')
        end

        def any_string_argument?(node)
          node.arguments.any? { |arg| arg.str_type? || arg.dstr_type? }
        end

        def any_string_hash_value?(node)
          node.arguments.any? do |arg|
            next unless arg.hash_type?

            arg.pairs.any? { |pair| pair.value.str_type? || pair.value.dstr_type? }
          end
        end
      end
    end
  end
end
