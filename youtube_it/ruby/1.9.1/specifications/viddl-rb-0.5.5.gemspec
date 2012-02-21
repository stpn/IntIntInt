# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "viddl-rb"
  s.version = "0.5.5"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.3.4") if s.respond_to? :required_rubygems_version=
  s.authors = ["Marc Seeger"]
  s.date = "2011-11-25"
  s.description = "An extendable commandline video downloader for flash video sites. Includes plugins for vimeo, youtube and megavideo"
  s.email = "mail@marc-seeger.de"
  s.executables = ["viddl-rb"]
  s.files = ["bin/viddl-rb"]
  s.homepage = "https://github.com/rb2k/viddl-rb"
  s.require_paths = ["."]
  s.rubyforge_project = "viddl-rb"
  s.rubygems_version = "1.8.10"
  s.summary = "An extendable commandline video downloader for flash video sites."

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<nokogiri>, [">= 0"])
      s.add_development_dependency(%q<rake>, [">= 0"])
      s.add_development_dependency(%q<minitest>, [">= 0"])
      s.add_development_dependency(%q<rest-client>, [">= 0"])
    else
      s.add_dependency(%q<nokogiri>, [">= 0"])
      s.add_dependency(%q<rake>, [">= 0"])
      s.add_dependency(%q<minitest>, [">= 0"])
      s.add_dependency(%q<rest-client>, [">= 0"])
    end
  else
    s.add_dependency(%q<nokogiri>, [">= 0"])
    s.add_dependency(%q<rake>, [">= 0"])
    s.add_dependency(%q<minitest>, [">= 0"])
    s.add_dependency(%q<rest-client>, [">= 0"])
  end
end
