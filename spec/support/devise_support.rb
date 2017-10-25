# frozen_string_literal: true

# This support package contains modules for authenticaiting
# devise users for request specs.

# This module authenticates users for request specs.#
module ValidUserRequestHelper
  # Define a method which signs in as a valid user.
  def sign_in_as_a_valid_user
    # Ask factory girl to generate a valid user for us.
    @user ||= FactoryBot.create :user

    # We action the login request using the parameters before we begin.
    # The login api_connection will match these to the user we just created in the factory, and authenticate us.
    post user_session_path, params: {'user[primary_email]': @user.primary_email, 'user[password]': @user.password}
    follow_redirect!
  end
end

# Configure these to modules as helpers in the appropriate tests.
RSpec.configure do |config|
  # Include the help for the request specs.
  config.include ValidUserRequestHelper, type: :request
end
