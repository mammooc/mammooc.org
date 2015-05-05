# -*- encoding : utf-8 -*-
# spec/support/wait_for_ajax.rb
# borrowed from https://robots.thoughtbot.com/automatically-wait-for-ajax-with-capybara

module WaitForAjax
  def wait_for_ajax
    endtime = Time.zone.now + 15.seconds
    Timeout.timeout(Capybara.default_wait_time) do
      loop until finished_all_ajax_requests? || Time.zone.now > endtime
    end
    # PhantomJS is much faster, a way too fast...
    sleep(0.33) if ENV['PHANTOM_JS'] == 'true'
  end

  def finished_all_ajax_requests?
    page.evaluate_script('jQuery.active').zero?
  end
end

RSpec.configure do |config|
  config.include WaitForAjax, type: :feature
end
