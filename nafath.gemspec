# frozen_string_literal: true

require_relative "lib/nafath/version"

Gem::Specification.new do |spec|
  spec.name          = "nafath"
  spec.version       = Nafath::VERSION
  spec.authors       = ["Shashank Patil"]
  spec.email         = ["patilshashank929@gmail.com"]

  spec.summary       = "A Ruby gem for integrating with the Nafath API"
  spec.description   = "This gem provides a convenient way to interact with the Nafath API for user verification."
  spec.homepage      = "https://github.com/Shank-001/nafath"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/Shank-001/nafath"
  # spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"
  spec.add_dependency "httparty", "~> 0.22.0"
  spec.add_dependency "jwt", "~> 2.10.1"
  spec.add_dependency "logger"

  spec.add_development_dependency "byebug"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rubocop", "~> 0.80"

  # For more information and examples about making a new gem, checkout our
  # guide at: https://bundler.io/guides/creating_gem.html
end
