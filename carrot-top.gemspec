# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = "carrot-top"
  s.version     = "0.0.5"
  s.authors     = ["Sean Porter"]
  s.email       = ["portertech@gmail.com"]
  s.homepage    = "https://github.com/portertech/carrot-top"
  s.summary     = "A Ruby library for querying the RabbitMQ Management API"
  s.description = "A Ruby library for querying the RabbitMQ Management API"

  s.rubyforge_project = "carrot-top"

  s.files         = `git ls-files`.split("\n").reject {|f| f =~ /(test|jpg)/}
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_paths = ["lib"]

  s.add_dependency "json"
  s.add_development_dependency "minitest"
  s.add_development_dependency "webmock"
end
