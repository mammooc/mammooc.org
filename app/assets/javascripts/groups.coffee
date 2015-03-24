# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$ ->
  $('#invitation_submit_button').click(send_invite)
  $('#dropdown_add_admin').on 'click', (event) -> add_administrator(event)
  $('#dropdown_demote_admin').on 'click', (event) -> demote_administrator(event)
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
     console.log('success')

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
      console.log('success')


