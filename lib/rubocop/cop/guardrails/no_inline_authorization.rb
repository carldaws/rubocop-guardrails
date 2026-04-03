# frozen_string_literal: true

module RuboCop
  module Cop
    module Guardrails
      # Flags inline authorization checks in controller actions.
      #
      # Authorization responses like `head :forbidden`,
      # `head :unauthorized`, or `render status: :forbidden`
      # should live in a `before_action` callback, not inline
      # in an action method. This keeps actions focused on
      # the happy path.
      #
      # @example
      #   # bad
      #   def destroy
      #     head :forbidden unless Current.user.can_administer?(@card)
      #     @card.destroy!
      #   end
      #
      #   # bad
      #   def destroy
      #     render status: :forbidden unless Current.user.can_administer?(@card)
      #     @card.destroy!
      #   end
      #
      #   # good — extract to a before_action
      #   before_action :ensure_can_administer_card, only: :destroy
      #
      #   def destroy
      #     @card.destroy!
      #   end
      #
      #   private
      #
      #   def ensure_can_administer_card
      #     head :forbidden unless Current.user.can_administer?(@card)
      #   end
      class NoInlineAuthorization < Base
        include VisibilityHelpers

        MSG = 'Extract authorization to a `before_action` callback.'

        RESTRICT_ON_SEND = %i[head render].freeze

        AUTHORIZATION_STATUSES = %i[forbidden unauthorized].to_set.freeze

        def on_send(node)
          add_offense(node) if authorization_response?(node) && in_public_method?(node)
        end
        alias on_csend on_send

        private

        def authorization_response?(node)
          case node.method_name
          when :head
            first_arg = node.first_argument
            first_arg && first_arg.sym_type? && AUTHORIZATION_STATUSES.include?(first_arg.value)
          when :render
            val = status_value(node)
            val && val.sym_type? && AUTHORIZATION_STATUSES.include?(val.value)
          end
        end

        def status_value(node)
          node.arguments.each do |arg|
            next unless arg.hash_type?

            arg.pairs.each do |pair|
              key = pair.key
              return pair.value if key.sym_type? && key.value == :status
            end
          end

          nil
        end

        def in_public_method?(node)
          method_node = node.each_ancestor(:any_def).first
          method_node && public_method?(method_node)
        end
      end
    end
  end
end
