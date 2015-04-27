# spec/support/wait_for_ajax.rb
# borrowed from https://robots.thoughtbot.com/automatically-wait-for-ajax-with-capybara

module WaitForAjax
  def wait_for_ajax
    endtime = Time.now + 15.seconds
    Timeout.timeout(Capybara.default_wait_time) do
      loop until finished_all_ajax_requests? or Time.now > endtime
    end
    # PhantomJS is much faster, a way too fast...
    if ENV['PHANTOM_JS'] == 'true'
      sleep(0.33)
    end
  end

  def finished_all_ajax_requests?
    page.evaluate_script('jQuery.active').zero?
  end
end

RSpec.configure do |config|
  config.include WaitForAjax, type: :feature
end
