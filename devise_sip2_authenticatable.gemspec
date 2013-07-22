$:.push File.expand_path("../lib", __FILE__)
require "devise_sip2_authenticatable/version"

Gem::Specification.new do |s|
  s.name     = 'devise_sip2_authenticatable'
  s.version  = DeviseSip2Authenticatable::VERSION.dup
  s.platform = Gem::Platform::RUBY
  s.summary  = 'Devise extension to allow authentication via Sip2'
  s.email = 'kardeiz@gmail.com'
  s.homepage = 'http://example.com/#'
  s.description = s.summary
  s.authors = ['Jacob Brown']
  s.license = 'MIT'

  s.files         = `git ls-files`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency('devise', '>= 3.0')
  
end
