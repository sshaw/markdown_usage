lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "markdown_usage/version"

Gem::Specification.new do |spec|
  spec.name          = "markdown-usage"
  spec.version       = MarkdownUsage::VERSION
  spec.authors       = ["Skye Shaw"]
  spec.email         = ["skye.shaw@gmail.com"]

  spec.summary       = %q{Output a colorized version of your program's usage using a Markdown document embedded in your script, from your project's README, or anywhere else.}
  spec.homepage      = "https://github.com/sshaw/markdown_usage"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "tty-markdown"
  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "climate_control", "~> 0.1"
  spec.add_development_dependency "io-grab", "~> 0.0.2"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "rake", "~> 10.0"
end
