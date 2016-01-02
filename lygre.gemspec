# -*- coding: utf-8 -*-
Gem::Specification.new do |s|
  s.name        = 'lygre'
  s.version     = '0.0.1'
  s.date        = '2014-07-20'
  s.summary     = "converts music formats gabc -> lilypond"

  s.description = <<-EOF
two of the free music typesetting applications most popular
among church musicians are LilyPond and Gregorio.

lygre gem currently provides tool *grely* converting Gregorio's
input format (gabc) to simple LilyPond input.

In future another tool for the other direction of conversion may be added.

As rb-music-theory is not at RubyGems, either install it before
attempting to 'gem install lygre', or get lygre's source from github
and install the dependencies by 'bundle install'.
EOF

  s.authors     = ["Jakub Pavlík"]
  s.email       = 'jkb.pavlik@gmail.com'
  s.files       = Dir['bin/*.rb'] + Dir['lib/*.rb'] + Dir['lib/lygre/*.rb'] + Dir['spec/*.rb']
  s.executables = ['grely.rb']
  s.homepage    =
    'http://github.com/igneus/lygre'
  s.licenses    = ['LGPL-3.0', 'MIT']

  s.add_runtime_dependency 'treetop', '~> 1.6'
  s.add_runtime_dependency 'polyglot', '~> 0.3'
  s.add_runtime_dependency 'rb-music-theory', '~> 0.1'

  s.add_development_dependency "rspec", '~> 3.4'
end
