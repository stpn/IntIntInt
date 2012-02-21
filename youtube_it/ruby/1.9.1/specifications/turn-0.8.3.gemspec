# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "turn"
  s.version = "0.8.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Tim Pease"]
  s.date = "2011-10-10"
  s.description = ""
  s.email = "tim.pease@gmail.com"
  s.executables = ["turn"]
  s.extra_rdoc_files = ["History.txt", "NOTICE.txt", "Release.txt", "Version.txt", "bin/turn", "license/GPLv2.txt", "license/MIT-LICENSE.txt", "license/RUBY-LICENSE.txt"]
  s.files = ["bin/turn", "History.txt", "NOTICE.txt", "Release.txt", "Version.txt", "license/GPLv2.txt", "license/MIT-LICENSE.txt", "license/RUBY-LICENSE.txt"]
  s.homepage = "http://gemcutter.org/gems/turn"
  s.rdoc_options = ["--main", "README.md"]
  s.require_paths = ["lib"]
  s.rubyforge_project = "turn"
  s.rubygems_version = "1.8.10"
  s.summary = "Test::Unit Reporter (New) -- new output format for Test::Unit"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<ansi>, [">= 0"])
      s.add_development_dependency(%q<bones-git>, [">= 1.2.4"])
      s.add_development_dependency(%q<bones>, [">= 3.7.1"])
    else
      s.add_dependency(%q<ansi>, [">= 0"])
      s.add_dependency(%q<bones-git>, [">= 1.2.4"])
      s.add_dependency(%q<bones>, [">= 3.7.1"])
    end
  else
    s.add_dependency(%q<ansi>, [">= 0"])
    s.add_dependency(%q<bones-git>, [">= 1.2.4"])
    s.add_dependency(%q<bones>, [">= 3.7.1"])
  end
end
