require 'rubygems'
require 'spork'

def setup_mailchimp
  ::Refinery::Mailchimp.api_key = '7e8e612edc7db50483bf107b7aea961b-us5'
end

def setup_environment
  puts "==> setup environment"
  # Configure Rails Environment
  ENV["RAILS_ENV"] ||= 'test'

  require File.expand_path("../dummy/config/environment", __FILE__)

  require 'rspec/rails'
  require 'capybara/rspec'
  require 'factory_girl_rails'

  Rails.backtrace_cleaner.remove_silencers!

  RSpec.configure do |config|
    config.mock_with :rspec
    config.treat_symbols_as_metadata_keys_with_true_values = true
    config.run_all_when_everything_filtered = true
    config.include FactoryGirl::Syntax::Methods
  end
end

def reload_the_app_and_route
  Dir["app/controllers/*/*/*.rb"].each do |controller|
    load controller
    puts "====>>>> loading #{controller}"
  end
  Dir["app/controllers/*/*/*/*.rb"].each do |controller|
    load controller
    puts "====>>>> loading #{controller}"
  end
  Dir["app/models/*/*/*.rb"].each do |model|
    load model
    puts "====>>>> loading #{model}"
  end
  require File.expand_path("../../config/routes", __FILE__)
end

def each_run
  puts "==> each run"
  ActiveSupport::Dependencies.clear

  FactoryGirl.reload
  reload_the_app_and_route

  # Requires supporting files with custom matchers and macros, etc,
  # in ./support/ and its subdirectories including factories.
  puts "=========================="
  ([Rails.root.to_s] | ::Refinery::Plugins.registered.pathnames).map{|p|
    Dir[File.join(p, 'spec', 'support', '**', '*.rb').to_s]
  }.flatten.sort.each do |support_file|
    require support_file
    print support_file.to_s.split("/")[-1]
    print "  "
  end
  puts ""
  puts "=========================="
  require File.expand_path("../../config/routes", __FILE__)
end

# If spork is available in the Gemfile it'll be used but we don't force it.
Spork.prefork do
  # Loading more in this block will cause your tests to run faster. However,
  # if you change any configuration or code from libraries loaded here, you'll
  # need to restart spork for it take effect.
  setup_environment
end

Spork.each_run do
  # This code will be run each time you run your specs.
  each_run
end
