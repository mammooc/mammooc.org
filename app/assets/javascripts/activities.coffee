ready = ->
  $('.remove-activity-current-user').click(delete_user_from_activity)
  $('.remove-activity-group').click(delete_group_from_activity)
  return

$(document).ready(ready)

delete_group_from_activity = () ->
  activity_id = $(this).data('activity_id')
  group_id = $(this).data('group_id')
  activity = $(this).closest('.newsfeed')

  $.ajax
    url: "/activities/#{activity_id}/delete_group_from_newsfeed_entry?group_id=#{group_id}"
    method: 'GET'
    error: (jqXHR, textStatus, errorThrown) ->
      console.log('group delete activity error')
      alert(I18n.t('global.ajax_failed'))
    success: (data, textStatus, jqXHR) ->
      activity.remove()
  return false

delete_user_from_activity = () ->
  activity_id = $(this).data('activity_id')
  activity = $(this).closest('.newsfeed')

  $.ajax
    url: "/activities/#{activity_id}/delete_user_from_newsfeed_entry"
    method: 'GET'
    error: (jqXHR, textStatus, errorThrown) ->
      console.log('user delete newsfeed error')
      alert(I18n.t('global.ajax_failed'))
    success: (data, textStatus, jqXHR) ->
      activity.remove()
  return false
