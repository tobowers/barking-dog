# -*- encoding: utf-8 -*-
$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)
require 'barking-dog/version'

Gem::Specification.new do |s|
  s.name        = "barking-dog"
  s.version     = BarkingDog::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = []
  s.email       = []
  s.homepage    = "http://rubygems.org/gems/barking-dog"
  s.summary     = "Is a service oriented service runner with internal pubsub and ZMQ"
  s.description = "Is a service oriented service runner with internal pubsub and ZMQ"

  s.required_rubygems_version = ">= 1.3.6"
  s.rubyforge_project         = "barking-dog"

  s.add_dependency("celluloid")
  s.add_dependency("celluloid-zmq")
  s.add_dependency("active_support")
  s.add_dependency("hashie")

  s.add_development_dependency "bundler", ">= 1.0.0.rc.5"
  s.add_development_dependency "rspec", "> 2.0.0"
  s.add_development_dependency "debugger"

  s.files        = `git ls-files`.split("\n")
  s.executables  = `git ls-files`.split("\n").select{|f| f =~ /^bin/}
  s.require_path = 'lib'
end
