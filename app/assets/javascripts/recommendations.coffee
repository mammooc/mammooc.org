# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

groups = []

ready = ->
  $('#recommendation_groups').focus(generate_groups_autocomplete)
  return

$(document).ready(ready)
$(document).on('page:load', ready)

generate_groups_autocomplete = () ->
  console.log('click')
  $.ajax
    url: '/groups.json'
    method: 'GET'
    error: (jqXHR, textStatus, errorThrown) ->
      console.log('groups error')
    success: (data, textStatus, jqXHR) ->
      console.log('groups success')
      for group in data
        groups.push(group.name)
      $("#recommendation_groups").tokenfield
        autocomplete:
          source: groups
          delay: 100
        showAutocompleteOnFocus: true
        delimiter: ' '
