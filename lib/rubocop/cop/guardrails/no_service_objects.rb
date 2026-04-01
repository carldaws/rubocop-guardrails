# frozen_string_literal: true

module RuboCop
  module Cop
    module Guardrails
      # Disallows service objects.
      #
      # Service objects are a common pattern but they aren't the Rails way.
      # Business logic belongs in your models — ActiveRecord models and
      # plain old Ruby objects that live in `app/models`.
      #
      # @example
      #   # bad - app/services/post_publisher.rb
      #   class PostPublisher
      #     def call
      #       post.update!(published: true)
      #     end
      #   end
      #
      #   # good - logic belongs in the model
      #   class Post < ApplicationRecord
      #     def publish
      #       update!(published: true)
      #     end
      #   end
      class NoServiceObjects < Base
        MSG = 'Avoid service objects. This logic belongs in your models.'

        def on_class(node)
          add_offense(node.loc.name)
        end
      end
    end
  end
end
