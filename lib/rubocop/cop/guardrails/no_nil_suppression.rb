# frozen_string_literal: true

module RuboCop
  module Cop
    module Guardrails
      # Bans the safe navigation operator (`&.`) and `try`/`try!`.
      #
      # Both mechanisms silently swallow `nil`, masking bugs where a
      # `NoMethodError` would be a better signal. If the receiver can
      # legitimately be `nil`, handle it with an explicit conditional.
      # The verbosity is intentional — it forces you to justify the
      # nil check, and makes it visible to reviewers.
      #
      # @example
      #   # bad
      #   user&.name
      #   user.try(:name)
      #   user.try!(:name)
      #
      #   # good — let it raise if nil is unexpected
      #   user.name
      #
      #   # good — handle nil explicitly
      #   user.name if user
      class NoNilSuppression < Base
        MSG_SAFE_NAV = 'Do not use safe navigation (`&.`). ' \
                       'If `nil` is actually expected, handle it with an explicit conditional.'

        MSG_TRY = 'Do not use `%<method>s`. ' \
                  'If `nil` is actually expected, handle it with an explicit conditional.'

        def on_csend(node)
          add_offense(node, message: MSG_SAFE_NAV)
        end

        def on_send(node)
          return unless %i[try try!].include?(node.method_name)

          add_offense(node, message: format(MSG_TRY, method: node.method_name))
        end
      end
    end
  end
end
