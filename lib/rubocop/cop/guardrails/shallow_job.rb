# frozen_string_literal: true

module RuboCop
  module Cop
    module Guardrails
      # Flags job `perform` methods with too many statements.
      #
      # Jobs should be thin wrappers that delegate to model methods.
      # A `perform` method with many statements is a sign that
      # business logic has leaked into the job layer.
      #
      # The `MaxStatements` option (default: 2) controls the
      # threshold.
      #
      # @example MaxStatements: 2 (default)
      #   # bad
      #   class NotifyRecipientsJob < ApplicationJob
      #     def perform(card)
      #       recipients = card.watchers - [card.creator]
      #       recipients.each do |user|
      #         NotificationMailer.card_updated(user, card).deliver_later
      #       end
      #       card.update!(notified_at: Time.current)
      #     end
      #   end
      #
      #   # good — delegate to the model
      #   class NotifyRecipientsJob < ApplicationJob
      #     def perform(card)
      #       card.notify_recipients
      #     end
      #   end
      class ShallowJob < Base
        MSG = 'Job `perform` has too many statements (%<count>d/%<max>d). Move logic to a model method.'

        def on_def(node)
          return unless node.method_name == :perform

          count = statement_count(node)
          return if count <= max_statements

          add_offense(node.loc.name, message: format(MSG, count: count, max: max_statements))
        end

        private

        def statement_count(node)
          return 0 unless node.body

          node.body.begin_type? ? node.body.children.size : 1
        end

        def max_statements
          cop_config['MaxStatements'] || 2
        end
      end
    end
  end
end
