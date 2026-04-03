# frozen_string_literal: true

module RuboCop
  module Cop
    module Guardrails
      # Detects non-RESTful route definitions.
      #
      # Routes should use `resources` and `resource` exclusively. When you
      # need a custom action, extract a new resource rather than adding
      # bare HTTP verb routes or `member`/`collection` blocks.
      #
      # @example
      #   # bad
      #   get '/posts/:id/publish', to: 'posts#publish'
      #
      #   resources :posts do
      #     member do
      #       get :publish
      #     end
      #   end
      #
      #   # good - extract a new resource
      #   resources :posts do
      #     resource :publication, only: :create
      #   end
      class RestfulRoutes < Base
        MSG_VERB = 'Use `resources` or `resource` instead of bare HTTP verb routes.'
        MSG_MEMBER = 'Use a new `resources` instead of `member` routes.'
        MSG_COLLECTION = 'Use a new `resources` instead of `collection` routes.'

        HTTP_VERBS = %i[get post put patch delete match].to_set.freeze

        RESTRICT_ON_SEND = [*HTTP_VERBS, :member, :collection].freeze

        # @!method route_draw_block?(node)
        def_node_matcher :route_draw_block?, <<~PATTERN
          (block (send (send (send (const nil? :Rails) :application) :routes) :draw) ...)
        PATTERN

        def on_send(node)
          if inside_routes_draw?(node)
            if HTTP_VERBS.include?(node.method_name)
              add_offense(node.loc.selector, message: MSG_VERB) unless inside_member_or_collection?(node)
            elsif node.method?(:member)
              add_offense(node.loc.selector, message: MSG_MEMBER)
            elsif node.method?(:collection)
              add_offense(node.loc.selector, message: MSG_COLLECTION)
            end
          end
        end
        alias on_csend on_send

        private

        def inside_routes_draw?(node)
          node.each_ancestor(:block).any? { |block| route_draw_block?(block) }
        end

        def inside_member_or_collection?(node)
          node.each_ancestor(:block).any? do |block|
            block.method?(:member) || block.method?(:collection)
          end
        end
      end
    end
  end
end
