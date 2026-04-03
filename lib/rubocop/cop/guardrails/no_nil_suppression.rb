# frozen_string_literal: true

module RuboCop
  module Cop
    module Guardrails
      # Bans the safe navigation operator (`&.`) and `try`/`try!`.
      #
      # Both mechanisms silently swallow `nil`, hiding the question
      # that matters: can this actually be nil? If it can't, drop
      # the operator and let a `NoMethodError` surface the real bug.
      # If it can, that's a concept worth naming — use an explicit
      # conditional or a method that describes what the nil case means.
      #
      # @example
      #   # bad
      #   pull_request.reviewer&.notify
      #   pull_request.reviewer.try(:notify)
      #
      #   # good — if reviewer is required, let it raise
      #   pull_request.reviewer.notify
      #
      #   # good — if reviewer is optional, name the business rule
      #   pull_request.notify_reviewer
      class NoNilSuppression < Base
        MSG_SAFE_NAV = 'Do not use safe navigation (`&.`). ' \
                       'If `nil` is actually expected, handle it with an explicit conditional.'

        MSG_TRY = 'Do not use `%<method>s`. ' \
                  'If `nil` is actually expected, handle it with an explicit conditional.'

        def on_csend(node)
          add_offense(node, message: MSG_SAFE_NAV)
        end

        def on_send(node)
          if %i[try try!].include?(node.method_name)
            add_offense(node, message: format(MSG_TRY, method: node.method_name))
          end
        end
      end
    end
  end
end
