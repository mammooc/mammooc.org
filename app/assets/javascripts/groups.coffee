# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$ ->
  $('#invitation_submit_button').click(send_invite)
  $('.dropdown_add_admin').on 'click', (event) -> add_administrator(event)
  $('.dropdown_demote_admin').on 'click', (event) -> demote_administrator(event)
  $('.dropdown_remove_member').on 'click', (event) -> remove_member(event)
  $('#remove_last_member_confirm_button').on 'click', (event) -> delete_group(event)
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
      console.log('error_add')
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
      console.log('error_demote')
    success: (data, textStatus, jqXHR) ->
      console.log('success_demote')
      change_style_to_member(user_id)
  event.preventDefault()

remove_member = (event) ->
  button = $(event.target)
  group_id = button.data('group_id')
  user_id = button.data('user_id')
  url = '/groups/' + group_id + '/condition_for_changing_member_status.json'
  data =
    changing_member : user_id

  $.ajax
    url: url
    data: data
    method: 'POST'
    error: (jqXHR, textStatus, errorThrown) ->
      console.log('error_status')
    success: (data, textStatus, jqXHR) ->
      console.log('success_status')
      if data.status == 'last_member'
        $('#confirmation_remove_last_member').modal('show')
      else if data.status == 'last_admin'
        console.log('last_admin')
      else if data.status == 'ok'
        remove_group_member(group_id, user_id)
  event.preventDefault()

remove_group_member = (group_id, user_id) ->
  url = '/groups/' + group_id + '/remove_group_member.json'
  data =
    removing_member : user_id

  $.ajax
    url: url
    data: data
    method: 'POST'
    error: (jqXHR, textStatus, errorThrown) ->
      console.log('error_remove')
    success: (data, textStatus, jqXHR) ->
      console.log('success_remove')
      delete_member_out_of_list(user_id)

delete_group = (event) ->
  button = $(event.target)
  group_id = button.data('group_id')
  url = '/groups/' + group_id + '.json'

  $.ajax
    url: url
    method: 'DELETE'
    error: (jqXHR, textStatus, errorThrown) ->
      console.log('error_delete_group')
    success: (data, textStatus, jqXHR) ->
      console.log('success_delete_group')
      $('#confirmation_remove_last_member').modal('hide')
      window.location.replace('/groups')
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

delete_member_out_of_list = (user_id) ->
  id = "#list_member_element_user_#{user_id}"
  $(id).html('')