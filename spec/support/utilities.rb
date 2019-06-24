module AutomationFramework
  # This class is for utility methods that can be used by all tests
  # rubocop:disable Metrics/ClassLength
  # rubocop:disable Style/GlobalVars
  class Utilities
    include Capybara::DSL
    include Capybara::RSpecMatchers
    include ::RSpec::Matchers
    include Net::SFTP
    require 'net/sftp'

    def env
      $config = YAML.load_file('spec/support/config.yml') if File.exist?('spec/support/config.yml')
      return @env = $config['env'].upcase if ENV['APP_ENV'].nil? && $config
      return @env = ENV['APP_ENV'].upcase if ENV['APP_ENV'].nil? == false
      @env = 'MARU'
    end
    
    # rubocop:disable Metrics/MethodLength, Metrics/CyclomaticComplexity
    def log(msg, severity = 'info')
      if @log.respond_to?(:level) == false
        @log = Logger.new 'logger.log'
        setup_log_level(get_data_from_config_file('log_level'))
      end
      case severity
      when 'progname' then @log.progname msg
      when 'debug' then @log.debug msg
      when 'info' then @log.info msg
      when 'warn' then @log.warn msg
      when 'error' then @log.error msg
      when 'fatal' then @log.fatal msg
      end
      puts msg
    end
    # rubocop:enable Metrics/MethodLength, Metrics/CyclomaticComplexity

    def setup_log_level(log_level)
      case log_level
      when 'info' then @log.level = Logger::INFO
      when 'debug' then @log.level = Logger::DEBUG
      when 'warn' then @log.level = Logger::WARN
      when 'error' then @log.level = Logger::ERROR
      when 'fatal' then @log.level = Logger::FATAL
      end
    end

    def default_max_wait_time(wait_time)
      return unless wait_time != ''
      Capybara.default_max_wait_time = Capybara.default_max_wait_time.to_i + wait_time.to_i
    end

    def get_data_from_config_file(property_name)
      config = YAML.safe_load(File.read(File.path('spec/support/config.yml'))) if $config
      config[property_name]
    end

    # rubocop:disable Metrics/MethodLength
    def different?(service_name, response_code, expected_response, actual_response)
      if response_code == '200'
        result = JsonCompare.get_diff(expected_response, actual_response)
        return true unless result != {}
        puts "\nDifference between expected response and actual response: #{result}"
        raise "FATAL: #{service_name} service call failed.\nExpected: #{expected_response} \n" \
              "Recieved: #{actual_response}".red
      else
        puts "FATAL: #{service_name} service returned response code #{response_code} expected" \
             ' 200'.red
        exit raise 'SEE SCRIPT OUTPUT FOR FATAL ERRORS!!!'
      end
    end
    # rubocop:enable Metrics/MethodLength

    def get_file_or_directory(file_name)
      File.expand_path("spec/support/assets/files/#{file_name}")
    end

    
    def browser
      config = YAML.load_file('spec/support/config.yml')
      config['browser'].upcase
    end

    # rubocop:disable Metrics/MethodLength
    def browser_launch(browser, url)
      case browser.upcase
      when 'IE'
        Capybara.register_driver :ie do |app|
          Capybara::Selenium::Driver.new(app, browser: :ie)
        end
        Capybara.default_driver = :ie
      when 'CHROME'
        Capybara.register_driver :selenium_chrome do |app|
          Capybara::Selenium::Driver.new(app, browser: :chrome)
        end
        Capybara.current_driver = :selenium_chrome
      else
        Capybara.register_driver :firefox do |app|
          Capybara::Selenium::Driver.new(app, browser: :firefox)
        end
        Capybara.default_driver = :firefox
      end
      visit(url)
    end
    # rubocop:enable Metrics/MethodLength

    def close_all_windows
      count = page.driver.browser.window_handles.length
      while count > 1
        page.driver.browser.close
        switchtonewlyopenedwindow
        count -= 1
      end
    end

  
    def wait_for_element(element, iterations = 5)
      count = 0
      found = false
      while count < iterations && !found
        found = page.has_css?(element)
        count += 1
        puts "Element: #{element}, Count: #{count}, Found: #{found}".green unless found
        sleep(1)
      end
      found
    end
  end
  # rubocop:enable Metrics/ClassLength
  # rubocop:enable Style/GlobalVars
end
