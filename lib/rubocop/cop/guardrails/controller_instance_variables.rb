# frozen_string_literal: true

module RuboCop
  module Cop
    module Guardrails
      # Flags controller actions that assign too many instance variables.
      #
      # Actions that set many instance variables are doing too much.
      # Extract logic to the model layer, use a single rich object,
      # or split into smaller controllers.
      #
      # The `Max` option (default: 1) controls how many instance
      # variable assignments are allowed per action. Assignments in
      # `before_action` callbacks (private methods) are not counted.
      #
      # @example Max: 1 (default)
      #   # bad
      #   def show
      #     @card = Card.find(params[:id])
      #     @comments = @card.comments
      #     @related = @card.related_cards
      #   end
      #
      #   # good — one object, the view navigates from there
      #   def show
      #     @card = Card.find(params[:id])
      #   end
      class ControllerInstanceVariables < Base
        MSG = 'Too many instance variables in action (%<count>d/%<max>d). ' \
              'Let the view navigate from a single object.'

        def on_def(node)
          return unless public_method?(node)

          count = ivar_assignment_count(node)
          max = max_assignments
          return if count <= max

          add_offense(node.loc.name, message: format(MSG, count: count, max: max))
        end

        private

        def max_assignments
          cop_config['Max'] || 1
        end

        def ivar_assignment_count(node)
          return 0 unless node.body

          count = 0
          node.body.each_descendant(:ivasgn) { count += 1 }
          count
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
