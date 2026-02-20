# frozen_string_literal: true

require_relative "lib/redsys-ruby/version"

Gem::Specification.new do |spec|
  spec.name = "redsys-ruby"
  spec.version = RedsysRuby::VERSION
  spec.authors = ["smallPush"]
  spec.email = ["[EMAIL_ADDRESS]"]

  spec.summary = "A Ruby gem for making payments with Redsys."
  spec.description = "Implement Redsys HMAC SHA256 signature and payment parameters handling."
  spec.homepage = "https://github.com/smallPush/redsys-ruby"
  spec.license = "CC-BY-4.0"
  spec.required_ruby_version = ">= 3.2.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/smallPush/redsys-ruby"

  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ Gemfile .gitignore .rspec spec/])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "railties", "~> 7.0"
end
