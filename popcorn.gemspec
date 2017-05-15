# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'popcorn/version'

Gem::Specification.new do |spec|
  spec.name          = "popcorn"
  spec.version       = Popcorn::VERSION
  spec.authors       = ["Adam Strickland"]
  spec.email         = ["adam.strickland@gmail.com"]

  spec.summary       = %q{Like OpenAPI, but don't like one big file?  Popcorn has you covered}
  spec.description   = %q{OpenAPI is an excellent tool for documenting APIs, and a convenient way to test-drive them as well.  However, the one-large-canonical-file-based-definition approach has some significant limitations.  Popcorn is a tool to help with that}
  spec.homepage      = "http://popcorn.github.io"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "http://rubygems.org"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "bin"
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "rubygems", "~> 2.0"
  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "rake", "~> 12.0"
  spec.add_development_dependency "rspec", "~> 3.6"
  spec.add_development_dependency "rspec-collection_matchers", "~> 1.1"
  spec.add_development_dependency "rubocop", "~> 0.48"
  spec.add_development_dependency "pry", "~> 0.10"

  spec.add_dependency "thor", "~> 0.19"
  spec.add_dependency "colorize", "~> 0.8"
  spec.add_dependency "activesupport", "~> 5.1"
  spec.add_dependency "mustache", "~> 1.0"
end
