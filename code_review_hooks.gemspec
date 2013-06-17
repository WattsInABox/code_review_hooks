# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'version'

Gem::Specification.new do |spec|
  spec.name          = "code_review_hooks"
  spec.version       = CodeReviewHooks::VERSION
  spec.authors       = ["Brian Johnson"]
  spec.email         = ["bjohnson@korrelate.com"]
  spec.description   = %q{Provides a script to submit code for review}
  spec.summary       = %q{Provides a script to submit code for review: code-review}
  spec.homepage      = ""
  spec.license       = "NONE"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
