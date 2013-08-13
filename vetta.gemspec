# -*- encoding: utf-8 -*-
$LOAD_PATH << File.expand_path('../lib/opal', __FILE__)
require 'vetta/version'

Gem::Specification.new do |s|
  s.name         = 'vetta'
  s.version      = Vetta::VERSION
  s.author       = 'meh.'
  s.email        = 'meh@schizofreni.co'
  s.homepage     = 'https://github.com/meh/vetta'
  s.summary      = '.'
  s.description  = '..'

  s.files          = `git ls-files`.split("\n")
  s.executables    = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.test_files     = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_paths  = ['lib']

  s.add_dependency 'opal', '>= 0.4.1'
	s.add_dependency 'opal-browser'

  s.add_development_dependency 'opal-spec'
  s.add_development_dependency 'rake'
end
