# frozen_string_literal: true

require_relative 'lib/rubocop/guardrails/version'

Gem::Specification.new do |spec|
  spec.name = 'rubocop-guardrails'
  spec.version = RuboCop::Guardrails::VERSION
  spec.authors = ['Carl Dawson']
  spec.email = ['carldawson@hey.com']

  spec.summary = 'RuboCop cops that keep Rails apps on the golden path'
  spec.description = 'Opinionated cops for developers who prefer conventional ' \
                     'Rails — rich models, RESTful controllers, shallow jobs, no service objects.'
  spec.homepage = 'https://github.com/carldaws/rubocop-guardrails'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 3.1.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri'] = "#{spec.homepage}/blob/main/CHANGELOG.md"
  spec.metadata['default_lint_roller_plugin'] = 'RuboCop::Guardrails::Plugin'
  spec.metadata['rubygems_mfa_required'] = 'true'

  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ Gemfile .gitignore .rspec spec/ .rubocop.yml])
    end
  end
  spec.require_paths = ['lib']

  spec.add_dependency 'lint_roller', '~> 1.1'
  spec.add_dependency 'rubocop', '>= 1.72.2'
end
