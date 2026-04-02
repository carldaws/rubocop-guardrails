# frozen_string_literal: true

require 'spec_helper'

# The cop is scoped to app/jobs/**/*.rb via default config.
# Here we test the offense detection logic in isolation.
RSpec.describe RuboCop::Cop::Guardrails::ShallowJob, :config do
  let(:cop_config) { { 'MaxStatements' => 2 } }

  it 'does not register an offense for a single statement' do
    expect_no_offenses(<<~RUBY)
      class NotifyJob < ApplicationJob
        def perform(card)
          card.notify_recipients
        end
      end
    RUBY
  end

  it 'does not register an offense at exactly MaxStatements' do
    expect_no_offenses(<<~RUBY)
      class NotifyJob < ApplicationJob
        def perform(card)
          card.notify_recipients
          card.mark_as_notified
        end
      end
    RUBY
  end

  it 'registers an offense when exceeding MaxStatements' do
    expect_offense(<<~RUBY)
      class NotifyJob < ApplicationJob
        def perform(card)
            ^^^^^^^ Job `perform` has too many statements (3/2). Move logic to a model method.
          recipients = card.watchers
          recipients.each { |u| notify(u) }
          card.update!(notified_at: Time.current)
        end
      end
    RUBY
  end

  it 'does not register an offense for an empty perform' do
    expect_no_offenses(<<~RUBY)
      class NoopJob < ApplicationJob
        def perform
        end
      end
    RUBY
  end

  it 'does not register an offense for other methods' do
    expect_no_offenses(<<~RUBY)
      class NotifyJob < ApplicationJob
        def perform(card)
          card.notify_recipients
        end

        private

        def prepare(card)
          card.reload
          card.validate!
          card.prepare_notification
        end
      end
    RUBY
  end
end
