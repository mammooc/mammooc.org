
ready = ->
  $('#sync-user-course-button').on 'click', (event) -> synchronizeCourse(event)
  return

$(document).ready(ready)

synchronizeCourse = (event) ->
  button = $(event.target)
  user_id = button.data('user_id')
  url = "/users/#{user_id}/synchronize_courses.json"
  $.ajax
    url: url
    method: 'GET'
    error: (jqXHR, textStatus, errorThrown) ->
      console.log('error_synchronize')
      alert(I18n.t('global.ajax_failed'))
    success: (data, textStatus, jqXHR) ->
      for mooc_provider, result of data.synchronization_state
        if result != true
          window.location.replace(result)
      $("div.user-courses-container").html(data.partial)
  event.preventDefault()
