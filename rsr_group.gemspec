# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rsr_group/version'

Gem::Specification.new do |spec|
  spec.required_ruby_version = '>= 2.0'

  spec.name          = "rsr_group"
  spec.version       = RsrGroup::VERSION
  spec.authors       = ["Dale Campbell"]
  spec.email         = ["oshuma@gmail.com"]

  spec.summary       = %q{RSR Group Ruby library}
  spec.description   = %q{Connect to RSR Group data via FTP.}
  spec.homepage      = "https://github.com/ammoready/rsr_group"
  spec.license       = "MIT"

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end

  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "smarter_csv", "~> 1.1.4"

  spec.add_development_dependency "activesupport", "~> 5"
  spec.add_development_dependency "bundler", "~> 1.15"
  spec.add_development_dependency "memory_profiler", "~> 0.9"
  spec.add_development_dependency "rake", ">= 12.3.3"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "webmock", "~> 1.20"
end
