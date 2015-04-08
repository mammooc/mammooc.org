# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

group_ids = []
groups_autocomplete = []
users_autocomplete = []

ready = ->
  $('#recommendation_related_group_ids').focus(generate_groups_autocomplete)
  $('#recommendation_related_user_ids').focus(generate_users_autocomplete)
  return

$(document).ready(ready)
$(document).on('page:load', ready)

generate_groups_autocomplete = () ->
  get_my_groups()
  $("#recommendation_related_group_ids").tokenfield
    autocomplete:
      source: groups_autocomplete
      delay: 100
    showAutocompleteOnFocus: true
    delimiter: ' '

get_my_groups = () ->
  group_ids = []
  groups_autocomplete = []
  $.ajax
    url: '/groups.json'
    method: 'GET'
    async: false
    error: (jqXHR, textStatus, errorThrown) ->
      console.log('error_get_my_groups')
    success: (data, textStatus, jqXHR) ->
      console.log('success_get_my_groups')
      for group in data
        group_ids.push(group.id)
        groups_autocomplete.push({ value: group.id, label: group.name })


generate_users_autocomplete = () ->
  get_my_groups()
  for group_id in group_ids
    $.ajax
      url: '/groups/' + group_id + '/members.json'
      async: false
      method: 'GET'
      error: (jqXHR, textStatus, errorThrown) ->
        console.log('users error')
      success: (data, textStatus, jqXHR) ->
        console.log('users success')
        for user in data.group_members
          users_autocomplete.push({ value: user.id, label: user.first_name + ' ' + user.last_name })

  $("#recommendation_related_user_ids").tokenfield
    autocomplete:
      source: users_autocomplete
      delay: 100
    showAutocompleteOnFocus: true
    delimiter: ' '
