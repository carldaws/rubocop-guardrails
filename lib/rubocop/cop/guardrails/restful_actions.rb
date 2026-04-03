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
        include VisibilityHelpers

        MSG = 'Non-RESTful action `%<method>s`. Add a new resource to represent this action.'

        RESTFUL_ACTIONS = %i[index show new create edit update destroy].to_set.freeze

        def on_def(node)
          if !RESTFUL_ACTIONS.include?(node.method_name) && in_class?(node) && public_method?(node)
            add_offense(node.loc.name, message: format(MSG, method: node.method_name))
          end
        end

        private

        def in_class?(node)
          node.each_ancestor(:class).any?
        end
      end
    end
  end
end
