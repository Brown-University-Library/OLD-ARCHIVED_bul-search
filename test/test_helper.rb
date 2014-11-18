ENV["RAILS_ENV"] ||= "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  ActiveRecord::Migration.check_pending!

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  # Add more helper methods to be used by all tests here...

  # fixes ``ActionView::Template::Error: undefined method `authenticate' for nil:NilClass`` error,
  #  ...which appears when trying to access a page that uses the devise/user model, like the catalog record page.
  # from <http://stackoverflow.com/a/4308872>, which leads to <https://github.com/plataformatec/devise#test-helpers>.
  include Devise::TestHelpers

end
