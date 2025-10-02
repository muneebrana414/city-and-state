# frozen_string_literal: true

require_relative "lib/city/and/state/version"

Gem::Specification.new do |spec|
  spec.name = "city-and-state"
  spec.version = CityState::VERSION
  spec.authors = ["muneebrana414"]
  spec.email = ["muneebrana414@gmail.com"]

  spec.summary = "Simple country, state, and city lookups with vendored data."
  spec.description = "Provides framework-agnostic helpers to list countries, states, and cities using local data files (no external gem dependency)."
  spec.homepage = "https://github.com/muneebrana414/city-and-state"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.1.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/muneebrana414/city-and-state"
  spec.metadata["changelog_uri"] = "https://github.com/muneebrana414/city-and-state/blob/master/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # No external dependency on city-state; optional runtime dependencies may be added here
  spec.add_dependency "rubyzip", ">= 2.3"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
