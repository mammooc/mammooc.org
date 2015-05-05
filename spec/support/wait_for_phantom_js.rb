# -*- encoding : utf-8 -*-
module WaitForPhantomJs
  def wait_for_phantom_js
    # PhantomJS is much faster, a way too fast...
    sleep(0.33) if ENV['PHANTOM_JS'] == 'true'
  end
end

RSpec.configure do |config|
  config.include WaitForPhantomJs, type: :feature
end
