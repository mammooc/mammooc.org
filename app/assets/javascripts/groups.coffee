# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$ ->
  console.log('init_before')
  $('#invitation_submit_button').click(send_invite)
  $('#add_administrators_submit_button').click(add_administrators)
  console.log('init_after')
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

add_administrators = () ->
  console.log('admins_before')
  group_id = $('#group_id').val()
  url = '/groups/' + group_id + '/add_administrators.json'
  user_ids = [$('#user_id').val()] if $('#checkbox_add_as_admin').val()
  console.log(user_ids)
  data =
    administrators : user_ids

  $.ajax
    url: url
    data: data
    method: 'POST'
    error: (jqXHR, textStatus, errorThrown) ->
      $('.administrator-form').hide()
      $('.administrator-error').text(errorThrown)
    success: (data, textStatus, jqXHR) ->
      $('#add_group_administrators').modal('hide')
  console.log('admins_after')