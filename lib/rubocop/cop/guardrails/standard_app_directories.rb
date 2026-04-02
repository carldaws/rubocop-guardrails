# frozen_string_literal: true

module RuboCop
  module Cop
    module Guardrails
      # Prevents non-standard directories under `app/`.
      #
      # Rails provides a conventional directory structure. Custom
      # directories like `app/services/`, `app/decorators/`, or
      # `app/form_objects/` scatter domain logic that belongs in
      # `app/models/`.
      #
      # The `AllowedDirectories` option lists the standard Rails
      # directories. Add to it if your project has a legitimate
      # need for additional directories.
      #
      # @example
      #   # bad — app/services/post_publisher.rb
      #   class PostPublisher
      #     def call
      #       post.update!(published: true)
      #     end
      #   end
      #
      #   # bad — app/decorators/post_decorator.rb
      #   class PostDecorator < SimpleDelegator
      #   end
      #
      #   # good — app/models/post/publisher.rb
      #   class Post::Publisher
      #     def call
      #       post.update!(published: true)
      #     end
      #   end
      class StandardAppDirectories < Base
        MSG = 'Non-standard app directory `%<directory>s`. Keep domain logic in `app/models/`.'

        DEFAULT_DIRECTORIES = %w[
          channels
          controllers
          helpers
          jobs
          mailers
          mailboxes
          models
          views
        ].to_set.freeze

        def on_class(node)
          dir = app_subdirectory
          return unless dir
          return if allowed_directories.include?(dir)

          add_offense(node.loc.name, message: format(MSG, directory: dir))
        end

        private

        def app_subdirectory
          match = processed_source.file_path.match(%r{app/([^/]+)/})
          match && match[1]
        end

        def allowed_directories
          @allowed_directories ||=
            (cop_config['AllowedDirectories'] || DEFAULT_DIRECTORIES.to_a).to_set
        end
      end
    end
  end
end
