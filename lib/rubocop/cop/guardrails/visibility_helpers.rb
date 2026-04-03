# frozen_string_literal: true

module RuboCop
  module Cop
    module Guardrails
      # Shared visibility-detection helpers for cops that only flag public methods.
      module VisibilityHelpers
        private

        def public_method?(node)
          !inline_visibility_modifier?(node) && effective_visibility(node) == :public
        end

        def inline_visibility_modifier?(node)
          parent = node.parent
          parent && visibility_call?(parent)
        end

        def effective_visibility(node)
          body = node.parent
          if body && body.begin_type?
            modifier = body.children
                           .take_while { |child| !child.equal?(node) }
                           .select { |child| bare_visibility_call?(child) }
                           .last
            modifier ? modifier.method_name : :public
          else
            :public
          end
        end

        def visibility_call?(node)
          node.send_type? && %i[private protected].include?(node.method_name)
        end

        def bare_visibility_call?(node)
          node.send_type? && node.arguments.empty? && %i[private protected public].include?(node.method_name)
        end
      end
    end
  end
end
