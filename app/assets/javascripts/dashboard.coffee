
ready = ->
  $('#sync-course-button').click(synchronizeCourse)
  return

$(document).ready(ready)

synchronizeCourse = () ->
  url = '/users/synchronize_courses.json'
  $.ajax
    url: url
    method: 'GET'
    error: (jqXHR, textStatus, errorThrown) ->
      console.log('error_synchronize')
      alert(I18n.t('global.ajax_failed'))
    success: (data, textStatus, jqXHR) ->
      $("div.user-courses-container").html(data.partial)
  event.preventDefault()
