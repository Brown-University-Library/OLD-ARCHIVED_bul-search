# Set up gems listed in the Gemfile.
ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../Gemfile', __FILE__)

require 'bundler/setup' if File.exists?(ENV['BUNDLE_GEMFILE'])

# caused error
#     couldn't find file 'font-awesome' with type 'text/css'
# on load of the home page
# require 'font-awesome-rails'
