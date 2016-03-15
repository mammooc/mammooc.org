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

  def newsletter_for_new_courses(email_adress, user, courses)
    @courses = courses
    @user = user

    mail(to: email_adress, subject: 'New MOOCs available')
  end

  # rubocop:disable ParameterLists

  def obligatory_recommendation_user_notification(email_adress, user, course, current_user, root_url)
    @user = user
    @course = course
    @author = current_user
    @root_url = root_url

    mail(to: email_adress, subject: 'A course was made obligatory for you')
  end

  def obligatory_recommendation_group_notification(email_adress, user, group, course, current_user, root_url)
    @user = user
    @group = group
    @course = course
    @author = current_user
    @root_url = root_url

    mail(to: email_adress, subject: 'A course was made obligatory for one of your groups')
  end

  # rubocop:enable ParameterLists
end
