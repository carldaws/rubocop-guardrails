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
        include VisibilityHelpers

        MSG = 'Too many instance variables in action (%<count>d/%<max>d). ' \
              'Let the view navigate from a single object.'

        def on_def(node)
          if public_method?(node)
            count = ivar_assignment_count(node)
            max = max_assignments
            add_offense(node.loc.name, message: format(MSG, count: count, max: max)) if count > max
          end
        end

        private

        def max_assignments
          cop_config['Max'] || 1
        end

        def ivar_assignment_count(node)
          body = node.body
          body ? body.each_descendant(:ivasgn).count : 0
        end
      end
    end
  end
end
