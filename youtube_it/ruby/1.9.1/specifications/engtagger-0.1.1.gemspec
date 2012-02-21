# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "engtagger"
  s.version = "0.1.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Yoichiro Hasebe"]
  s.date = "2008-05-14"
  s.description = "A Ruby port of Perl Lingua::EN::Tagger, a probability based, corpus-trained  tagger that assigns POS tags to English text based on a lookup dictionary and  a set of probability values. The tagger assigns appropriate tags based on  conditional probabilities--it examines the preceding tag to determine the  appropriate tag for the current word. Unknown words are classified according to  word morphology or can be set to be treated as nouns or other parts of speech.   The tagger also extracts as many nouns and noun phrases as it can, using a set  of regular expressions."
  s.email = "yohasebe@gmail.com"
  s.extra_rdoc_files = ["History.txt", "LICENSE.txt", "Manifest.txt", "README.txt"]
  s.files = ["History.txt", "LICENSE.txt", "Manifest.txt", "README.txt"]
  s.homepage = "http://engtagger.rubyforge.org"
  s.rdoc_options = ["--main", "README.txt"]
  s.require_paths = ["lib"]
  s.rubyforge_project = "engtagger"
  s.rubygems_version = "1.8.10"
  s.summary = "English Part-of-Speech Tagger Library; a Ruby port of Lingua::EN::Tagger"

  if s.respond_to? :specification_version then
    s.specification_version = 2

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<hpricot>, [">= 0"])
      s.add_runtime_dependency(%q<hoe>, [">= 1.5.1"])
    else
      s.add_dependency(%q<hpricot>, [">= 0"])
      s.add_dependency(%q<hoe>, [">= 1.5.1"])
    end
  else
    s.add_dependency(%q<hpricot>, [">= 0"])
    s.add_dependency(%q<hoe>, [">= 1.5.1"])
  end
end
