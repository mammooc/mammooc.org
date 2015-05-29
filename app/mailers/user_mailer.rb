# -*- encoding : utf-8 -*-
class UserMailer < ApplicationMailer
  def group_invitation_mail(email_adress, link, group, user, root_url)
    @group = group
    @user = user
    @link = link
    @root_url = root_url
    mail(to: email_adress, subject: "You were invited to join a group on #{t('global.app_name')}")
  end

  def reminder_for_bookmarked_course(email_adress, user, course)
    @course = course
    @user = user

    mail(to: email_adress, subject: 'A bookmarked course starts soon')
  end

end
