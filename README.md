# rubocop-guardrails

RuboCop cops that keep Rails app on the golden path.

Rails is a convention-over-configuration framework, but it's easy to drift — especially when AI coding agents are involved. Agents pull from a broad training set and love to introduce service objects, decorators, form objects, and other patterns that aren't advocated for by the framework itself. These cops push back, keeping your app conventional: rich models, RESTful controllers, shallow jobs, and nothing in between.

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
