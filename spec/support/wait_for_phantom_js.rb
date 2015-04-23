module WaitForPhantomJs
  def wait_for_phantom_js
    # PhantomJS is much faster, a way too fast...
    if ENV['PHANTOM_JS'] == 'true'
      sleep(0.33)
    end
  end
end

RSpec.configure do |config|
  config.include WaitForPhantomJs, type: :feature
end
