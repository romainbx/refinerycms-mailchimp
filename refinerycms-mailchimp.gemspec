Gem::Specification.new do |s|
  s.platform          = Gem::Platform::RUBY
  s.name              = %q{refinerycms-mailchimp}
  s.authors           = ['Ian Terell', 'Johan Bruning']
  s.email             = %q{ian.terrell@gmail.com}
  s.homepage          = %q{https://github.com/ianterrell/refinerycms-mailchimp}
  s.version           = %q{0.1.0}
  s.description       = %q{Ruby on Rails Mailchimp engine for Refinery CMS.  Manage your campaigns right from the admin!}
  s.date              = "#{Date.today.strftime("%Y-%m-%d")}"
  s.summary           = %q{Ruby on Rails Mailchimp engine for Refinery CMS}
  s.require_paths     = %w(lib)
  #s.files             = `git ls-files`.split("\n")
  s.files             = Dir["{app,config,db,lib}/**/*"] + ["readme.md"]

  s.add_dependency  'hominid',              '~> 3.0'

end
