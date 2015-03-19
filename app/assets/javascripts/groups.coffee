# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$ ->
  $('#invitation_submit_button').click(send_invite)
  $('#add_administrators_submit_button').click(add_administrators)
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
  group_id = $('#group_id').val()
  url = '/groups/' + group_id + '/add_administrators.json'
  user_ids = []
  $.each $('.add_as_admin_list_member'), (i, user) ->
    user_ids.push $("#user_id_#{i}").val() if $("#checkbox_add_as_admin_#{i}").prop('checked')
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