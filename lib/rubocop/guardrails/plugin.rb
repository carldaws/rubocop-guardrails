# frozen_string_literal: true

require 'lint_roller'

module RuboCop
  module Guardrails
    # A plugin that integrates rubocop-guardrails with RuboCop's plugin system.
    class Plugin < LintRoller::Plugin
      def about
        LintRoller::About.new(
          name: 'rubocop-guardrails',
          version: VERSION,
          homepage: 'https://github.com/carldawson/rubocop-guardrails',
          description: 'RuboCop cops that keep Rails apps on the golden path'
        )
      end

      def supported?(context)
        context.engine == :rubocop
      end

      def rules(_context)
        LintRoller::Rules.new(
          type: :path,
          config_format: :rubocop,
          value: Pathname.new(__dir__).join('../../../config/default.yml')
        )
      end
    end
  end
end
