# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

ready = ->
  $('.delete_bookmark_from_bookmark_list').on 'click', (event) -> deleteBookmarkFromList(event)
  return

$(document).ready(ready)

deleteBookmarkFromList = (event) ->
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
      console.log('SUCCESS')
  event.preventDefault()