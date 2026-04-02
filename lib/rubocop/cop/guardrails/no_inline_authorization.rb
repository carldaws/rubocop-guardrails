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
        MSG = 'Extract authorization to a `before_action` callback.'

        RESTRICT_ON_SEND = %i[head render].freeze

        AUTHORIZATION_STATUSES = %i[forbidden unauthorized].to_set.freeze

        def on_send(node)
          return unless authorization_response?(node)
          return unless in_public_method?(node)

          add_offense(node)
        end

        private

        def authorization_response?(node)
          case node.method_name
          when :head
            first_arg = node.first_argument
            first_arg&.sym_type? && AUTHORIZATION_STATUSES.include?(first_arg.value)
          when :render
            status_value(node).then { |val| val&.sym_type? && AUTHORIZATION_STATUSES.include?(val.value) }
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
          method_node = node.each_ancestor(:def, :defs).first
          return false unless method_node

          !in_private_section?(method_node)
        end

        def in_private_section?(method_node)
          return true if inline_visibility_modifier?(method_node)

          effective_visibility(method_node) != :public
        end

        def inline_visibility_modifier?(node)
          node.parent&.send_type? &&
            %i[private protected].include?(node.parent.method_name)
        end

        def effective_visibility(node)
          body = node.parent
          return :public unless body&.begin_type?

          body.children
              .take_while { |child| !child.equal?(node) }
              .select { |child| visibility_modifier?(child) }
              .last&.method_name || :public
        end

        def visibility_modifier?(node)
          node.send_type? &&
            node.arguments.empty? &&
            %i[private protected public].include?(node.method_name)
        end
      end
    end
  end
end
