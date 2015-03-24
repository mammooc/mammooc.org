# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$ ->
  $('#invitation_submit_button').click(send_invite)
  $('.dropdown_add_admin').on 'click', (event) -> add_administrator(event)
  $('.dropdown_demote_admin').on 'click', (event) -> demote_administrator(event)
  return

send_invite = () ->
	group_id = $('#group_id').val()
	url = '/groups/' + group_id + '/invite_members.json'
	data = 
		members : $('#text_area_invite_members').val()

	$.ajax
		url: url
		data: data
		method: 'POST'
		error: (jqXHR, textStatus, errorThrown) ->
			$('.invitation-form').hide()
			$('.invitation-error').text(errorThrown)
		success: (data, textStatus, jqXHR) ->
			$('#add_group_members').modal('hide')

add_administrator = (event) ->
  button = $(event.target)
  group_id = button.data('group_id')
  user_id = button.data('user_id')
  url = '/groups/' + group_id + '/add_administrator.json'
  data =
    additional_administrator : user_id

  $.ajax
    url: url
    data: data
    method: 'POST'
    error: (jqXHR, textStatus, errorThrown) ->
      console.log('error')
    success: (data, textStatus, jqXHR) ->
     console.log('success_add')
    change_style_to_admin(user_id)
  event.preventDefault()

demote_administrator = (event) ->
  button = $(event.target)
  group_id = button.data('group_id')
  user_id = button.data('user_id')
  url = '/groups/' + group_id + '/demote_administrator.json'
  data =
    demoted_admin : user_id

  $.ajax
    url: url
    data: data
    method: 'POST'
    error: (jqXHR, textStatus, errorThrown) ->
      console.log('error')
    success: (data, textStatus, jqXHR) ->
      console.log('success_demote')
      change_style_to_member(user_id)
  event.preventDefault()

change_style_to_admin = (user_id) ->
  id = "#list_member_element_user_#{user_id}"
  $(id).find('.list-members').addClass('admins')
  $(id).find('.dropdown_add_admin').text(I18n.t('groups.all_members.demote_admin'))
  $(id).find('.dropdown_add_admin').unbind('click')
  $(id).find('.dropdown_add_admin').on 'click', (event) -> demote_administrator(event)
  $(id).find('.dropdown_add_admin').addClass('dropdown_demote_admin').removeClass('dropdown_add_admin')


change_style_to_member = (user_id) ->
  id = "#list_member_element_user_#{user_id}"
  $(id).find('.list-members').removeClass('admins')
  $(id).find('.dropdown_demote_admin').text(I18n.t('groups.all_members.add_admin'))
  $(id).find('.dropdown_demote_admin').unbind('click')
  $(id).find('.dropdown_demote_admin').on 'click', (event) -> add_administrator(event)
  $(id).find('.dropdown_demote_admin').removeClass('dropdown_demote_admin').addClass('dropdown_add_admin')
