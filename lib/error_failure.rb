# frozen_string_literal: true

class ErrorFailure < Devise::FailureApp
  def recall
    request.env['PATH_INFO'] = attempted_path
    flash.now[:error] = i18n_message(:invalid)
    self.response = recall_app(warden_options[:recall]).call(request.env)
  end
end
