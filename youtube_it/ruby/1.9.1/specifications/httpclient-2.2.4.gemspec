# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "httpclient"
  s.version = "2.2.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Hiroshi Nakamura"]
  s.date = "2011-12-08"
  s.email = "nahi@ruby-lang.org"
  s.homepage = "http://github.com/nahi/httpclient"
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.10"
  s.summary = "gives something like the functionality of libwww-perl (LWP) in Ruby"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
