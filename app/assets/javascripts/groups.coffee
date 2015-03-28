# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/


ready = ->
  $('#invitation_submit_button').click(send_invite)
  $('.dropdown_add_admin').on 'click', (event) -> add_administrator(event)
  $('.dropdown_demote_admin').on 'click', (event) -> demote_administrator(event)
  $('.dropdown_remove_member').on 'click', (event) -> remove_member(event)
  $('#remove_member_confirm_button').on 'click', (event) -> remove_group_member(event)
  $('#remove_last_member_confirm_button').on 'click', (event) -> delete_group(event)
  $('#confirm_delete_group_last_admin_button').on 'click', (event) -> delete_group(event)
  $('#confirm_leave_group_last_admin_button').on 'click', (event) -> remove_last_admin(event)
  return

$(document).ready(ready)
$(document).on('page:load', ready)

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
      if data.status == 'last_member' || data.status == 'last_admin'
        $('#notice_demote_last_admin').modal('show')
      else if data.status == 'ok'
        demote_group_administrator(group_id, user_id)
  event.preventDefault()

demote_group_administrator = (group_id, user_id) ->
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

remove_member = (event) ->
  button = $(event.target)
  group_id = button.data('group_id')
  user_id = button.data('user_id')
  user_name = button.data('user_name')
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
        $('#confirmation_remove_last_admin').modal('show')
        $('#confirmation_remove_last_admin').find('#confirm_leave_group_last_admin_button').attr('data-user_id', user_id)
      else if data.status == 'ok'
        $('#confirmation_remove_member').modal('show')
        $('#confirmation_remove_member').find('#removing_user_name').text(user_name)
        $('#confirmation_remove_member').find('#remove_member_user_id').val(user_id)
  event.preventDefault()

remove_group_member = (event) ->
  button = $(event.target)
  group_id = button.data('group_id')
  user_id = $('#remove_member_user_id').val()
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
      $('#confirmation_remove_member').modal('hide')
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
      # if we still use turbolinks: Turbolinks.visit('/groups')
      window.location.replace('/groups')
  event.preventDefault()

remove_last_admin = (event) ->
  button = $(event.target)
  group_id = button.data('group_id')
  user_id = button.data('user_id')
  url = '/groups/' + group_id + '/all_members_to_administrators.json'

  $.ajax
    url: url
    method: 'GET'
    error: (jqXHR, textStatus, errorThrown) ->
      console.log('error_remove_last_admin')
    success: (data, textStatus, jqXHR) ->
      console.log('success_remove_last_admin')
      leave_group(group_id, user_id)
  event.preventDefault()

leave_group = (group_id, user_id) ->
  url = '/groups/' + group_id + '/remove_group_member.json'
  data =
    removing_member : user_id

  $.ajax
    url: url
    data: data
    method: 'POST'
    error: (jqXHR, textStatus, errorThrown) ->
      console.log('error_leave_group')
    success: (data, textStatus, jqXHR) ->
      console.log('success_leave_group')
      $('#confirmation_remove_last_admin').modal('hide')
      # if we still use turbolinks: Turbolinks.visit('/groups')
      window.location.replace('/groups')

change_style_to_admin = (user_id) ->
  id = "#list_member_element_user_#{user_id}"
  $(id).find('.name').addClass('admins')
  $(id).find('.dropdown_add_admin').text(I18n.t('groups.all_members.demote_admin'))
                                   .unbind('click')
                                   .on 'click', (event) -> demote_administrator(event)
                                   .addClass('dropdown_demote_admin').removeClass('dropdown_add_admin')


change_style_to_member = (user_id) ->
  id = "#list_member_element_user_#{user_id}"
  $(id).find('.name').removeClass('admins')
  $(id).find('.dropdown_demote_admin').text(I18n.t('groups.all_members.add_admin'))
                                      .unbind('click')
                                      .on 'click', (event) -> add_administrator(event)
                                      .removeClass('dropdown_demote_admin').addClass('dropdown_add_admin')

delete_member_out_of_list = (user_id) ->
  id = "#list_member_element_user_#{user_id}"
  $(id).remove()