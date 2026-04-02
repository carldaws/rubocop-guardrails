# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RuboCop::Cop::Guardrails::StandardAppDirectories, :config do
  let(:cop_config) do
    { 'AllowedDirectories' => %w[channels controllers helpers jobs mailers mailboxes models views] }
  end

  context 'when the file is in a non-standard directory' do
    it 'registers an offense for app/services/' do
      expect_offense(<<~RUBY, 'app/services/post_publisher.rb')
        class PostPublisher
              ^^^^^^^^^^^^^ Non-standard app directory `services`. Keep domain logic in `app/models/`.
        end
      RUBY
    end

    it 'registers an offense for app/decorators/' do
      expect_offense(<<~RUBY, 'app/decorators/post_decorator.rb')
        class PostDecorator
              ^^^^^^^^^^^^^ Non-standard app directory `decorators`. Keep domain logic in `app/models/`.
        end
      RUBY
    end

    it 'registers an offense for app/form_objects/' do
      expect_offense(<<~RUBY, 'app/form_objects/signup_form.rb')
        class SignupForm
              ^^^^^^^^^^ Non-standard app directory `form_objects`. Keep domain logic in `app/models/`.
        end
      RUBY
    end

    it 'registers an offense for namespaced classes' do
      expect_offense(<<~RUBY, 'app/services/posts/publish_service.rb')
        class Posts::PublishService
              ^^^^^^^^^^^^^^^^^^^^^ Non-standard app directory `services`. Keep domain logic in `app/models/`.
        end
      RUBY
    end
  end

  context 'when the file is in a standard directory' do
    it 'does not register an offense for app/models/' do
      expect_no_offenses(<<~RUBY, 'app/models/post.rb')
        class Post
        end
      RUBY
    end

    it 'does not register an offense for app/controllers/' do
      expect_no_offenses(<<~RUBY, 'app/controllers/posts_controller.rb')
        class PostsController
        end
      RUBY
    end

    it 'does not register an offense for app/jobs/' do
      expect_no_offenses(<<~RUBY, 'app/jobs/notify_job.rb')
        class NotifyJob
        end
      RUBY
    end

    it 'does not register an offense for nested standard directories' do
      expect_no_offenses(<<~RUBY, 'app/models/concerns/searchable.rb')
        class Searchable
        end
      RUBY
    end
  end

  context 'when the file is outside app/' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY, 'lib/some_library.rb')
        class SomeLibrary
        end
      RUBY
    end
  end

  it 'does not register an offense for modules' do
    expect_no_offenses(<<~RUBY, 'app/services/post_publishing.rb')
      module PostPublishing
      end
    RUBY
  end
end
