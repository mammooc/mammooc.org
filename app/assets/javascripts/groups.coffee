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
    if $("#checkbox_add_as_admin_#{i}").prop('checked')
      unless $("#checkbox_add_as_admin_#{i}").prop('disabled')
        user_id = $("#user_id_#{i}").val()
        user_ids.push user_id
        add_new_admin(user_id,i)
        $("#checkbox_add_as_admin_#{i}").attr('disabled', true)
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

add_new_admin = (user_id,i) ->
  $.ajax 'http://localhost:3000/users/' + user_id + '.json',
    success  : (data, status, xhr) ->
      user_link = 'http://localhost:3000/users/' + user_id
      name = data.first_name + ' ' + data.last_name
      $('.add_new_admin').append("<div class='row'><div class='col-md-12 list-members'><a href='' class='js_user_link_add_admin'><img src='/data/default.png' /><span class='js_user_name_add_admin'></span></a></div></div>")
      $('.js_user_link_add_admin').attr('class', "js_user_link_add_admin_#{i}")
      $(".js_user_link_add_admin_#{i}").attr('href', user_link)
      $('.js_user_name_add_admin').attr('class', "js_user_name_add_admin_#{i}")
      $(".js_user_name_add_admin_#{i}").append(name)
    error    : (xhr, status, err) ->
      console.log("Error "+err)