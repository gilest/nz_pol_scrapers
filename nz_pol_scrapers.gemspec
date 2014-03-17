Gem::Specification.new do |s|
  s.name              = 'nz_pol_scrapers'
  s.version           = '0.1.0'
  s.summary           = 'Wikipedia scrapers which parse information about NZ politics'
  s.description       = 'Wikipedia scrapers which parse information about NZ politics'
  s.author            = 'Giles Thompson'
  s.email             = ['iam@gilesthompson.co.nz']
  s.homepage          = 'http://github.com/gilest/nz_pol_scrapers'
  s.has_rdoc          = false
  s.files             = Dir.glob('lib/**/*')
  s.required_rubygems_version = '>=1.3.2'
  s.required_ruby_version = '>=1.9.2'

  s.add_dependency('nokogiri', '~> 1.6')
end
