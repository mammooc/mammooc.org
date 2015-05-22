
ready = ->
  $('#sync-group-course-button').on 'click', (event) -> synchronizeCourse(event)
  return

$(document).ready(ready)

synchronizeCourse = (event) ->
  button = $(event.target)
  group_id = button.data('group_id')
  url = "/groups/#{group_id}/synchronize_courses.json"
  $.ajax
    url: url
    method: 'GET'
    error: (jqXHR, textStatus, errorThrown) ->
      console.log('error_synchronize')
      alert(I18n.t('global.ajax_failed'))
    success: (data, textStatus, jqXHR) ->
  event.preventDefault()
