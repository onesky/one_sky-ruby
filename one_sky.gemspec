# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "one_sky/version"

Gem::Specification.new do |s|
  s.name        = "one_sky"
  s.version     = OneSky::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Junjun Olympia", "3dd13 Lau", "Matthew Rudy Jacobs"]
  s.email       = ["romeo.olympia@gmail.com", "tatonlto@gmail.com", "matthewrudyjacobs@gmail.com"]
  s.homepage    = "http://rubygems.org/gems/one_sky"
  s.summary     = %q{Ruby interface to the OneSky REST API}
  s.description = %q{OneSky is a community-powered translation service for web and mobile apps. This gem is the core interface to the REST API and is used by other specialty gems such the OneSky extension for I18n, i18n-one_sky.}

  s.rubyforge_project = "one_sky"

  s.add_dependency "json", ">= 1.4.6"
  s.add_dependency "rest-client", "~> 1.6.1"

  s.add_development_dependency "rspec", "~> 2.2.0"
  s.add_development_dependency "bundler", ">= 1.0.0"
  s.add_development_dependency "time_freeze"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
