# frozen_string_literal: true

require 'simplecov'

if ENV['CIRCLE_ARTIFACTS']
  require 'coveralls'

  SimpleCov.formatters = [
    SimpleCov::Formatter::HTMLFormatter,
    Coveralls::SimpleCov::Formatter
  ]

  dir = File.join('..', '..', '..', ENV['CIRCLE_ARTIFACTS'], 'coverage')
  SimpleCov.coverage_dir(dir)
end

SimpleCov.start do
  add_filter '/spec/'
  add_filter '/config'

  add_group 'Controllers', 'app/controllers'
  add_group 'Concerns', 'app/controllers/concerns'
  add_group 'Helpers', 'app/helpers'
  add_group 'Mailers', 'app/mailers'
  add_group 'Models', 'app/models'
  add_group 'Views', 'app/views'
  add_group 'Workers', 'app/workers'
  add_group 'JSON API', 'app/resources'
  add_group 'Libraries', 'lib'
end
require 'public_activity/testing'
require 'factory_bot_rails'
require 'devise'
require 'support/devise_support'
require 'support/wait_for_ajax'
require 'capybara/rspec'
require 'capybara/poltergeist'
require 'selenium/webdriver'
require 'sidekiq/testing'

if ENV['HEADLESS_TEST'] == 'true' || ENV['USER'] == 'vagrant'
  require 'headless'

  headless = Headless.new
  headless.start
end

if ENV['PHANTOM_JS'] == 'true'
  Capybara.register_driver :poltergeist do |app|
    Capybara::Poltergeist::Driver.new(app, window_size: [1280, 960])
  end
  Capybara.javascript_driver = :poltergeist
else
  Capybara.register_driver :selenium do |app|
    profile = Selenium::WebDriver::Firefox::Profile.new
    profile['intl.accept_languages'] = 'en'
    options = Selenium::WebDriver::Firefox::Options.new
    options.profile = profile
    driver = Capybara::Selenium::Driver.new(app, browser: :firefox, capabilities: options)
    driver.browser.manage.window.resize_to(1280, 960)
    driver
  end
  Capybara.javascript_driver = :selenium
end

Capybara.server = :webrick
Capybara.server_port = 3333

# This file was generated by the `rails generate rspec:install` command. Conventionally, all
# specs live under a `spec` directory, which RSpec adds to the `$LOAD_PATH`.
# The generated `.rspec` file contains `--require spec_helper` which will cause this
# file to always be loaded, without a need to explicitly require it in any files.
#
# Given that it is always loaded, you are encouraged to keep this file as
# light-weight as possible. Requiring heavyweight dependencies from this file
# will add to the boot time of your test suite on EVERY test run, even for an
# individual file that may not need all of that loaded. Instead, consider making
# a separate helper file that requires the additional dependencies and performs
# the additional setup, and require it from the spec files that actually need it.
#
# The `.rspec` file also contains a few flags that are not defaults but that
# users commonly want.
#
# See http://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration
RSpec.configure do |config|
  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before do |example|
    if example.metadata[:type] == :feature
      DatabaseCleaner.strategy = :truncation
      if ENV['PHANTOM_JS'] == 'true' && example.metadata[:js]
        Capybara.current_driver = :poltergeist
        Capybara.current_session.driver.headers = {'ACCEPT-LANGUAGE' => 'en'}
      end
    else
      DatabaseCleaner.strategy = :transaction
    end
    DatabaseCleaner.start

    allow_any_instance_of(AmazonS3).to receive(:new_aws_resource).and_return(instance_double('AmazonS3'))
    allow_any_instance_of(AmazonS3).to receive(:get_data).and_return(Base64.encode64(File.open(Rails.root.join('public', 'data', 'icons', 'courses.png')).read))
    allow_any_instance_of(AmazonS3).to receive(:get_object).and_return(true)
    allow_any_instance_of(AmazonS3).to receive(:put_data).and_return(true)
    allow_any_instance_of(AmazonS3).to receive(:get_url).and_return('/data/icons/courses.png')
    allow(User).to receive(:process_uri).and_return(nil)
    allow(Course).to receive(:process_uri).and_return(nil)
  end

  config.after do
    DatabaseCleaner.clean
  end

  # rspec-expectations config goes here. You can use an alternate
  # assertion/expectation library such as wrong or the stdlib/minitest
  # assertions if you prefer.
  config.expect_with :rspec do |expectations|
    # This option will default to `true` in RSpec 4. It makes the `description`
    # and `failure_message` of custom matchers include text for helper methods
    # defined using `chain`, e.g.:
    # be_bigger_than(2).and_smaller_than(4).description
    #   # => "be bigger than 2 and smaller than 4"
    # ...rather than:
    #   # => "be bigger than 2"
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end
  # rspec-mocks config goes here. You can use an alternate test double
  # library (such as bogus or mocha) by changing the `mock_with` option here.
  config.mock_with :rspec do |mocks|
    # Prevents you from mocking or stubbing a method that does not exist on
    # a real object. This is generally recommended, and will default to
    # `true` in RSpec 4.
    mocks.verify_partial_doubles = true
  end

  # The settings below are suggested to provide a good initial experience
  # with RSpec, but feel free to customize to your heart's content.
  #   # These two settings work together to allow you to limit a spec run
  #   # to individual examples or groups you care about by tagging them with
  #   # `:focus` metadata. When nothing is tagged with `:focus`, all examples
  #   # get run.
  #   config.filter_run :focus
  #   config.run_all_when_everything_filtered = true
  #
  #   # Limits the available syntax to the non-monkey patched syntax that is recommended.
  #   # For more details, see:
  #   #   - http://myronmars.to/n/dev-blog/2012/06/rspecs-new-expectation-syntax
  #   #   - http://teaisaweso.me/blog/2013/05/27/rspecs-new-message-expectation-syntax/
  #   #   - http://myronmars.to/n/dev-blog/2014/05/notable-changes-in-rspec-3#new__config_option_to_disable_rspeccore_monkey_patching
  #   config.disable_monkey_patching!
  #
  #   # Many RSpec users commonly either run the entire suite or an individual
  #   # file, and it's useful to allow more verbose output when running an
  #   # individual spec file.
  #   if config.files_to_run.one?
  #     # Use the documentation formatter for detailed output,
  #     # unless a formatter has already been configured
  #     # (e.g. via a command-line flag).
  #     config.default_formatter = 'doc'
  #   end
  #
  #   # Print the 10 slowest examples and example groups at the
  #   # end of the spec run, to help surface which specs are running
  #   # particularly slow.
  #   config.profile_examples = 10
  #
  #   # Run specs in random order to surface order dependencies. If you find an
  #   # order dependency and want to debug it, you can fix the order by providing
  #   # the seed, which is printed after each run.
  #   #     --seed 1234
  #   config.order = :random
  #
  #   # Seed global randomization in this process using the `--seed` CLI option.
  #   # Setting this allows you to use `--seed` to deterministically reproduce
  #   # test failures related to randomization by passing the same `--seed` value
  #   # as the one that triggered the failure.
  #   Kernel.srand config.seed
end
