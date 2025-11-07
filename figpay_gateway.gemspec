# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'figpay_gateway/version'

Gem::Specification.new do |spec|
  spec.name          = "figpay_gateway"
  spec.version       = FigpayGateway::VERSION
  spec.authors       = ["Ben Eggett"]
  spec.email         = ["beneggett@gmail.com"]

  spec.summary       = %q{ FigPay Gateway (NMI) Api }
  spec.description   = %q{ Ruby wrapper for interacting with FigPay Gateway. FigPay is a white label gateway for NMI. Built with portability in mind for other NMI white-label providers. }
  spec.homepage      = "https://github.com/beneggett/figpay_gateway"
  spec.license       = "MIT"

  spec.required_ruby_version = ">= 3.0.0"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "https://rubygems.org"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", ">= 2.0"
  spec.add_development_dependency "rake", ">= 13.0"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "vcr"
  spec.add_development_dependency "webmock"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "guard"
  spec.add_development_dependency "guard-minitest"
  spec.add_development_dependency "coveralls"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "minitest-focus"
  spec.add_development_dependency "dotenv"
  spec.add_dependency "httparty", ">= 0.14.0"
  spec.add_dependency "activesupport"

end
