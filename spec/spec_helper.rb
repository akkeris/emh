require File.expand_path('../../config/environment', __FILE__)
require 'capybara'
require 'capybara/rspec'
require 'capybara-screenshot/rspec'
require 'csv'
require 'dotenv'
require 'support/utilities'
require 'support/application'
require 'rspec/expectations'
require 'require_all'
require 'net/https'
require 'pry'
require 'json'
require 'colorize'
require 'rspec/retry'
require 'oauth2'
require 'rspec'
require 'mailinator'
require 'rest-client'
require 'json-compare'
require 'mongo'
require 'timeout'
include RSpec::Core::Pending
require_rel '/support/apps/'

# rubocop:disable Style/GlobalVars
$config = YAML.load_file('spec/support/config.yml') if File.exist?('spec/support/config.yml')

# rubocop:disable Style/ConditionalAssignment
if ENV['APP_ENV'].nil? && $config
  app_env = $config['env'].upcase
elsif ENV['APP_ENV'].nil? == false
  app_env = ENV['APP_ENV'].upcase
else
  app_env = 'MARU'
end
# rubocop:enable Style/ConditionalAssignment

dotenv_files = ["./config/environments/.env.#{app_env}.local",
                "./config/environments/.env.#{app_env}",
                './config/environments/.env.local',
                './config/environments/.env']
Dotenv.load(*dotenv_files.map(&:downcase))

Capybara.configure do |config|
  config.run_server = true
  config.default_max_wait_time = 15
  config.match = :prefer_exact
  config.ignore_hidden_elements = true
  config.visible_text_only = true
  config.automatic_reload = true
  config.default_driver = :selenium
end


RSpec.configure do |config|
  config.include Capybara::DSL
  config.include Capybara::RSpecMatchers
  config.formatter = :documentation
  config.verbose_retry = true
  config.display_try_failure_messages = true
  config.default_retry_count = 2
  config.default_sleep_interval = 2
  config.filter_run_excluding broken: true
  Capybara.register_driver :logging_selenium_chrome do |app|
       caps = Selenium::WebDriver::Remote::Capabilities.chrome(loggingPrefs:{browser: 'ALL'})
       browser_options = ::Selenium::WebDriver::Chrome::Options.new()
           puts "Is running headless in docker!"
           browser_options.args << '--headless'
           browser_options.args << '--disable-gpu'
           browser_options.args << '--window-size=1980,1980'
           browser_options.args << '--disable-dev-shm-usage'
           browser_options.args << '--no-sandbox'
      Capybara::Selenium::Driver.new(app, :browser => :chrome, options: browser_options,  desired_capabilities: caps)
    Capybara.javascript_driver = :logging_selenium_chrome
    Capybara.current_driver = :selenium_chrome
    browser = Capybara.current_session.driver.browser
    browser.manage.delete_all_cookies
    Capybara.reset_sessions!
    Capybara.current_session.driver.quit
end


  # rubocop:enable Style/GlobalVars, Lint/ShadowingOuterLocalVariable
end
