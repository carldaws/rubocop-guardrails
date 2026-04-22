# frozen_string_literal: true

module RuboCop
  module Cop
    module Guardrails
      # Discourages guard clauses (conditional early returns).
      #
      # Guard clauses obscure the actual flow of a method. In short
      # methods, prefer a conditional expression. In longer methods,
      # one guard clause is tolerated at the very beginning.
      #
      # The `MinMethodLength` option (default: 10) controls the
      # threshold. Methods longer than this are allowed one leading
      # guard clause.
      #
      # @example
      #   # bad
      #   def something
      #     return if thing.nil?
      #
      #     thing.do_something
      #   end
      #
      #   # good — use a conditional expression
      #   def something
      #     thing.do_something if thing.present?
      #   end
      #
      #   # good — use an expanded conditional
      #   def something
      #     unless thing.nil?
      #       thing.do_something
      #     end
      #   end
      #
      #   # good — long method, one guard clause at the top
      #   def something
      #     return unless valid?
      #
      #     step_one
      #     step_two
      #     step_three
      #     # ...
      #   end
      class NoGuardClauses < Base
        MSG = 'Avoid guard clauses. Prefer a conditional expression.'

        def on_def(node)
          guards = leading_guard_clauses(node)
          allowed = method_length(node) > min_method_length ? 1 : 0

          guards.drop(allowed).each { |guard| add_offense(guard) }
        end
        alias on_defs on_def

        private

        def leading_guard_clauses(node)
          if node.body.nil?
            []
          else
            statements = node.body.begin_type? ? node.body.children : [node.body]
            preamble = statements.take_while { |s| guard_clause?(s) || s.lvasgn_type? }
            preamble.select { |s| guard_clause?(s) }
          end
        end

        def guard_clause?(node)
          node.if_type? &&
            (one_armed_return?(node.if_branch, node.else_branch) ||
              one_armed_return?(node.else_branch, node.if_branch))
        end

        def one_armed_return?(branch, other)
          branch && branch.return_type? && other.nil?
        end

        def method_length(node)
          node.loc.end.line - node.loc.keyword.line + 1
        end

        def min_method_length
          cop_config['MinMethodLength'] || 10
        end
      end
    end
  end
end
