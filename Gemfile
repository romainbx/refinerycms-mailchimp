source 'http://rubygems.org'

gemspec

gem 'refinerycms', :git => 'git://github.com/resolve/refinerycms.git'
gem 'refinerycms-settings', :git => 'git://github.com/parndt/refinerycms-settings.git'

group :development, :test do
  gem 'refinerycms-testing', :git => 'git://github.com/resolve/refinerycms.git'
  gem 'guard-rspec', '~> 0.6.0'
  gem 'sqlite3'

  platforms :ruby do
    gem 'spork', '~> 0.9.0.rc'
    gem 'guard-spork'

    unless ENV['TRAVIS']
      require 'rbconfig'
      if RbConfig::CONFIG['target_os'] =~ /darwin/i
        gem 'rb-fsevent', '>= 0.3.9'
        gem 'ruby_gntp'
      end
      if RbConfig::CONFIG['target_os'] =~ /linux/i
        gem 'rb-inotify', '>= 0.5.1'
        gem 'libnotify'
        gem 'therubyracer', '~> 0.9.9'
      end
    end
  end
end
# Refinery/rails should pull in the proper versions of these
group :assets do
  gem 'sass-rails'
  gem 'coffee-rails'
  gem 'uglifier'
end

gem 'jquery-rails'
