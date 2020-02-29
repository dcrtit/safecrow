
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "safecrow/version"

Gem::Specification.new do |spec|
  spec.name          = "safecrow"
  spec.version       = Safecrow::VERSION
  spec.authors       = ["McAlex"]
  spec.email         = ["mcalexvrn@yandex.ru"]

  spec.summary       = %q{SDK for Safecrow API v3 }
  spec.homepage      = "https://github.com/dcrtit/safecrow"
  spec.license       = "MIT"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.2"
  spec.add_dependency "curb"
  spec.add_dependency "multi_json"
  spec.add_dependency "oj"
end
