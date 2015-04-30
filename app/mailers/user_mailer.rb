class UserMailer < ApplicationMailer

  def group_invitation_mail(email_adress, link, group, user, root_url)
    @group = group
    @user = user
    @link = link
    @root_url = root_url
    mail(to: email_adress, subject: "You were invited to join a group on #{t('global.mammooc')}")
  end

end
