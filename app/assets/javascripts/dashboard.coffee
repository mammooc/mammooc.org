
ready = ->
  $('#sync-user-course-button').on 'click', (event) -> synchronizeCourse(event)
  $('#sync-user-dates-button').on 'click', (event) -> synchronizeDates(event)
  $('.delete_bookmark_on_dashboard').on 'click', (event) -> deleteBookmarkOnDashboard(event)
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
        if result == false
          alert(I18n.t('dashboard.error_synchronize_courses', provider: mooc_provider))
        else if result != true
          window.location.replace(result)
      $("div.user-courses-container").html(data.partial)
  event.preventDefault()

synchronizeDates = (event) ->
  button = $(event.target)
  user_id = button.data('user_id')
  url = "/users/#{user_id}/synchronize_dates.json"
  $.ajax
    url: url
    method: 'GET'
    error: (jqXHR, textStatus, errorThrown) ->
      console.log('error_synchronize_dates')
      alert(I18n.t('global.ajax_failed'))
    success: (data, textStatus, jqXHR) ->
      console.log('success_synchronize_dates')
      for mooc_provider, result of data.synchronization_state
        if result == false
          alert(I18n.t('dashboard.error_synchronize_dates', provider: mooc_provider))
        else if result != true
          window.location.replace(result)
      $("div.user-dates-container").html(data.partial)
  event.preventDefault()

deleteBookmarkOnDashboard = (event) ->
  entry = $(event.target).parent()
  current_course_id = entry.data('course_id')
  current_user_id = entry.data('user_id')
  url = "/bookmarks/delete"
  data =
    course_id: current_course_id
    user_id: current_user_id

  $.ajax
    url: url
    data: data
    method: 'POST'
    error: (jqXHR, textStatus, errorThrown) ->
      console.log('error delete bookmark')
      alert(I18n.t('global.ajax_failed'))
    success: (data, textStatus, jqXHR) ->
      entry.parent().hide()
  event.preventDefault()
