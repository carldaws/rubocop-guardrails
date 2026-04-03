# frozen_string_literal: true

module RuboCop
  module Cop
    module Guardrails
      # Flags transaction blocks in controllers.
      #
      # Transactions indicate business logic that belongs in a model
      # method. Controllers should orchestrate — call a single model
      # method that handles the transaction internally.
      #
      # @example
      #   # bad
      #   class Cards::ClosuresController < ApplicationController
      #     def create
      #       ActiveRecord::Base.transaction do
      #         @card.create_closure!(user: Current.user)
      #         @card.track_event(:closed)
      #       end
      #     end
      #   end
      #
      #   # good — model method wraps the transaction
      #   class Cards::ClosuresController < ApplicationController
      #     def create
      #       @card.close
      #     end
      #   end
      class ControllerTransaction < Base
        MSG = 'Avoid transactions in controllers. Move business logic to a model method.'

        def on_block(node)
          add_offense(node.send_node) if node.method?(:transaction)
        end
        alias on_numblock on_block
        alias on_itblock on_block
      end
    end
  end
end
