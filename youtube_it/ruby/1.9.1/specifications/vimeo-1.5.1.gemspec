# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "vimeo"
  s.version = "1.5.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Matt Hooks"]
  s.date = "2012-02-08"
  s.description = "A full featured Ruby implementation of the Vimeo API."
  s.email = "matthooks@gmail.com"
  s.extra_rdoc_files = ["CHANGELOG.rdoc", "LICENSE"]
  s.files = ["CHANGELOG.rdoc", "LICENSE"]
  s.homepage = "http://github.com/matthooks/vimeo"
  s.rdoc_options = ["--main", "README.rdoc", "--inline-source", "--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubyforge_project = "vimeo"
  s.rubygems_version = "1.8.10"
  s.summary = "A full featured Ruby implementation of the Vimeo API."

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<shoulda>, [">= 2.11.3"])
      s.add_development_dependency(%q<fakeweb>, [">= 1.2.6"])
      s.add_development_dependency(%q<ruby-prof>, [">= 0.9.2"])
      s.add_runtime_dependency(%q<httparty>, [">= 0.4.5"])
      s.add_runtime_dependency(%q<json>, [">= 1.1.9"])
      s.add_runtime_dependency(%q<oauth>, [">= 0.4.3"])
      s.add_runtime_dependency(%q<httpclient>, [">= 2.1.5.2"])
      s.add_runtime_dependency(%q<multipart-post>, [">= 1.0.1"])
    else
      s.add_dependency(%q<shoulda>, [">= 2.11.3"])
      s.add_dependency(%q<fakeweb>, [">= 1.2.6"])
      s.add_dependency(%q<ruby-prof>, [">= 0.9.2"])
      s.add_dependency(%q<httparty>, [">= 0.4.5"])
      s.add_dependency(%q<json>, [">= 1.1.9"])
      s.add_dependency(%q<oauth>, [">= 0.4.3"])
      s.add_dependency(%q<httpclient>, [">= 2.1.5.2"])
      s.add_dependency(%q<multipart-post>, [">= 1.0.1"])
    end
  else
    s.add_dependency(%q<shoulda>, [">= 2.11.3"])
    s.add_dependency(%q<fakeweb>, [">= 1.2.6"])
    s.add_dependency(%q<ruby-prof>, [">= 0.9.2"])
    s.add_dependency(%q<httparty>, [">= 0.4.5"])
    s.add_dependency(%q<json>, [">= 1.1.9"])
    s.add_dependency(%q<oauth>, [">= 0.4.3"])
    s.add_dependency(%q<httpclient>, [">= 2.1.5.2"])
    s.add_dependency(%q<multipart-post>, [">= 1.0.1"])
  end
end
