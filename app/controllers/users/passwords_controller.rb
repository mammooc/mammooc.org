class Users::PasswordsController < Devise::PasswordsController

  def new
    self.resource = resource_class.new
  end

  def create
    flash['error'] ||= []
    self.resource = resource_class.send_reset_password_instructions(resource_params)
    yield resource if block_given?

    if successfully_sent?(resource)
      respond_with({}, location: after_sending_reset_password_instructions_path_for(resource_name))
    else
      redirect_to new_user_password_path
      #respond_with(resource)
    end
    puts ('________________')
    Rails.logger.debug(resource.errors.inspect)
    resource.errors.each do |key, value|
      flash['error'] << "#{t(key)} #{value}"
      puts ('_GOT AN ERROR <3_')
      Rails.logger.debug(flash['error'].inspect)
    end
  end

end
