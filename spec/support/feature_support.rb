def capybara_sign_in(user)
  visit new_user_session_path
  fill_in 'login_email', with: user.primary_email
  fill_in 'login_password', with: user.password
  click_button 'submit_sign_in'
end

def capybara_sign_out(user)
  visit root_path
  click_link "#{user.first_name} #{user.last_name}"
  click_link I18n.t('navbar.sign_out')
end
