require_relative 'lib/logviewer/version'

Gem::Specification.new do |spec|
  spec.name          = "logviewer"
  spec.version       = LogViewer::VERSION
  spec.authors       = ["Justin Bishop"]
  spec.email         = ["jubishop@gmail.com"]

  spec.summary       = "Convert NDJSON log files to HTML for easy viewing"
  spec.description   = "A command-line tool that converts NDJSON log files into readable HTML format with filtering capabilities by log level"
  spec.homepage      = "https://github.com/jubishop/logviewer"
  spec.license       = "MIT"

  spec.required_ruby_version = ">= 2.5.0"

  spec.files         = Dir["lib/**/*", "bin/*", "README.md", "LICENSE", "*.gemspec"]
  spec.bindir        = "bin"
  spec.executables   = ["logviewer"]
  spec.require_paths = ["lib"]

  # No runtime dependencies - using only Ruby stdlib (json, optparse, fileutils)

  # Development dependencies
  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 13.0"
end
