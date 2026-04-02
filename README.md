# rubocop-guardrails

RuboCop cops that keep Rails apps on the golden path.

Rails is a convention-over-configuration framework, but it's easy to drift — especially when AI coding agents are involved. Agents pull from a broad training set and love to introduce service objects, decorators, form objects, and other patterns that aren't advocated for by the framework itself. These cops push back, keeping your app conventional: rich models, RESTful controllers, shallow jobs, and nothing in between.

## What it catches

### Controllers

**ControllerInstanceVariables** — flags actions that set more than one instance variable. If your action needs `@card`, `@comments`, and `@related`, that's three queries the view shouldn't know about. Let the view navigate from a single object.

```ruby
# bad
def show
  @card = Card.find(params[:id])
  @comments = @card.comments
  @related = @card.related_cards
end

# good
def show
  @card = Card.find(params[:id])
end
```

**ControllerTransaction** — flags `transaction` blocks in controllers. If you're wrapping multiple operations in a transaction, that's business logic that belongs in a model method.

```ruby
# bad
def create
  ActiveRecord::Base.transaction do
    @card.create_closure!(user: Current.user)
    @card.track_event(:closed)
  end
end

# good
def create
  @card.close
end
```

**NoInlineAuthorization** — flags `head :forbidden` and `render status: :forbidden` (or `:unauthorized`) inside public action methods. Authorization checks belong in `before_action` callbacks.

```ruby
# bad
def destroy
  head :forbidden unless Current.user.can_administer?(@card)
  @card.destroy!
end

# good
before_action :ensure_can_administer_card, only: :destroy

def destroy
  @card.destroy!
end
```

**RestfulActions** — flags non-RESTful public actions. If you need a `publish` action, extract a new controller with standard RESTful actions instead.

```ruby
# bad
class PostsController < ApplicationController
  def publish
  end
end

# good
class Posts::PublicationsController < ApplicationController
  def create
  end
end
```

### Routes

**RestfulRoutes** — flags bare HTTP verb routes (`get`, `post`, etc.), `member` blocks, and `collection` blocks. Use `resources` and `resource` and add new controllers when you need custom actions.

```ruby
# bad
resources :cards do
  post :close
  member do
    patch :publish
  end
end

# good
resources :cards do
  resource :closure, only: :create
  resource :publication, only: :create
end
```

### Jobs

**ShallowJob** — flags `perform` methods with more than 2 statements (configurable). Jobs should be thin wrappers that delegate to model methods, not containers for business logic.

```ruby
# bad
class NotifyRecipientsJob < ApplicationJob
  def perform(card)
    recipients = card.watchers - [card.creator]
    recipients.each { |u| NotificationMailer.card_updated(u, card).deliver_later }
    card.update!(notified_at: Time.current)
  end
end

# good
class NotifyRecipientsJob < ApplicationJob
  def perform(card)
    card.notify_recipients
  end
end
```

### Project structure

**StandardAppDirectories** — flags classes in non-standard `app/` subdirectories. No `app/services/`, `app/decorators/`, `app/form_objects/`, or `app/components/`. Domain logic belongs in `app/models/`.

```ruby
# bad — app/services/post_publisher.rb
class PostPublisher
  def call
    post.update!(published: true)
  end
end

# good — app/models/post/publisher.rb
class Post::Publisher
  def call
    post.update!(published: true)
  end
end
```

The list of allowed directories is configurable via `AllowedDirectories`.

### Code style

**NoGuardClauses** — flags guard clauses (conditional early returns) at the beginning of methods. In short methods, prefer a conditional expression. Methods longer than `MinMethodLength` (default: 10) are allowed one guard clause.

```ruby
# bad
def something
  return if thing.nil?

  thing.do_something
end

# good
def something
  thing.do_something if thing
end
```

### Tests

**NoTestStrings** — flags hardcoded string literals in test assertions and finders. When copy changes, tests that assert on strings break for the wrong reason. Assert against the source value, an i18n key, or a predicate instead. Also flags `find_by` and `where` with string values — use fixtures.

```ruby
# bad
assert_equal "Published", card.status
assert_includes response.body, "Welcome back"
card = Card.find_by(title: "Logo Design")

# good
assert card.published?
assert_equal I18n.t("flash.success"), flash[:notice]
card = cards(:logo)
```

Assertions where strings are part of the API (`assert_difference`, `assert_select`, `assert_changes`, etc.) are not flagged.

## Configuration

All cops are enabled by default. Each cop is scoped to the relevant file patterns via `Include`. Override any setting in your `.rubocop.yml`:

```yaml
Guardrails/ShallowJob:
  MaxStatements: 3

Guardrails/ControllerInstanceVariables:
  Max: 2

Guardrails/NoGuardClauses:
  MinMethodLength: 15

Guardrails/StandardAppDirectories:
  AllowedDirectories:
    - channels
    - controllers
    - helpers
    - jobs
    - mailers
    - mailboxes
    - models
    - views
    - validators  # add your own
```

## Installation

Add it to your application's Gemfile:

```ruby
gem "rubocop-guardrails", require: false
```

## Usage

### RuboCop plugin system (>= 1.72)

Add to your `.rubocop.yml`:

```yaml
plugins:
  - rubocop-guardrails
```

### Legacy

```yaml
require:
  - rubocop-guardrails
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests.

To generate a new cop:

```bash
bundle exec rake 'new_cop[Guardrails/CopName]'
```

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
