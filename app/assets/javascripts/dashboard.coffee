# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

ready = ->
  $('#sync-course-button').click(synchronizeCourse)
  return

$(document).ready(ready)

synchronizeCourse = () ->
  url = '/api_connection/synchronize_courses_for_user.json'
  $.ajax
    url: url
    method: 'GET'
    error: (jqXHR, textStatus, errorThrown) ->
      console.log('error_status')
    success: (data, textStatus, jqXHR) ->
      $("div.user-courses-container").html(data.partial)
  event.preventDefault()