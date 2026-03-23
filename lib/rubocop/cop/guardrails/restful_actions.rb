# frozen_string_literal: true

module RuboCop
  module Cop
    module Guardrails
      # Prevents non-RESTful actions in controllers.
      #
      # Rails advocates for RESTful resources. When you need a custom
      # action, extract a new controller with standard RESTful actions.
      #
      # @example
      #   # bad
      #   class PostsController < ApplicationController
      #     def publish
      #     end
      #   end
      #
      #   # good - extract a new resource
      #   class Posts::PublicationsController < ApplicationController
      #     def create
      #     end
      #   end
      class RestfulActions < Base
        MSG = 'Non-RESTful action `%<method>s`. Add a new resource to represent this action.'

        RESTFUL_ACTIONS = %i[index show new create edit update destroy].to_set.freeze

        def on_def(node)
          return if RESTFUL_ACTIONS.include?(node.method_name)
          return unless in_class?(node)
          return unless public_method?(node)

          add_offense(node.loc.name, message: format(MSG, method: node.method_name))
        end

        private

        def in_class?(node)
          node.each_ancestor(:class).any?
        end

        def public_method?(node)
          return false if inline_visibility_modifier?(node)

          effective_visibility(node) == :public
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
