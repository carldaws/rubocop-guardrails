# frozen_string_literal: true

module RuboCop
  module Cop
    module Guardrails
      # Flags conditionals that rely on bare truthiness instead of an
      # explicit predicate method. `if user` hides the real question:
      # are you checking for nil, blank, empty, or something else?
      # Pick the predicate that says what you mean.
      #
      # @example
      #   # bad
      #   do_something if user
      #   return unless account
      #
      #   # good
      #   do_something if user.present?
      #   return unless account.nil?
      class ExplicitConditional < Base
        MSG_IF = 'Use a predicate method (e.g. `present?`) instead of a bare truthiness check.'
        MSG_UNLESS = 'Use `nil?` instead of a bare truthiness check.'

        COMPARISON_OPERATORS = %i[== != < > <= >= <=> =~ !~ === !].to_set.freeze
        VARIABLE_TYPES = %i[lvar ivar cvar gvar].to_set.freeze

        def on_if(node)
          unless node.ternary?
            condition = unwrap_begin(node.condition)
            if bare_check?(condition)
              add_offense(condition, message: node.unless? ? MSG_UNLESS : MSG_IF)
            end
          end
        end

        private

        def unwrap_begin(node)
          node = node.children.first while node.begin_type?
          node
        end

        def bare_check?(node)
          VARIABLE_TYPES.include?(node.type) || (node.send_type? && bare_send?(node))
        end

        def bare_send?(node)
          name = node.method_name
          !name.end_with?('?') && !COMPARISON_OPERATORS.include?(name)
        end
      end
    end
  end
end
