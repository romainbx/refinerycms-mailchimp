source 'http://rubygems.org'

gemspec

gem 'refinerycms'
gem 'refinerycms-settings'
gem 'refinerycms-blog'

group :development, :test do
  gem 'refinerycms-testing'
  gem 'guard-rspec', '~> 0.6.0'
  gem 'sqlite3'
  gem 'pry-rails'
  gem 'haml-rails'

  platforms :ruby do
    gem 'spork', '~> 0.9.0.rc'
    gem 'guard-spork'
    gem 'launchy'

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
