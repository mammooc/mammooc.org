ready = ->
  $('#submit-rating-button').on 'click', (event) -> sendCourseReview(event)
  return

$(document).ready(ready)

sendCourseReview = (event) ->
  button = $(event.target)
  user_id = button.data('user_id')
  course_id = button.data('course_id')
  rating_input = $("#rating-input").rating('rate')
  rating_textarea = $("#rating-textarea").val()
  course_status = $("#course-status-selector").val()
  rate_anonymously = $("#rate-anonymously-checkbox").is(':checked')

  url = "/courses/#{course_id}/send_evaluation.json"
  $.ajax
    url: url
    data: {}
    method: 'GET'
    error: (jqXHR, textStatus, errorThrown) ->
      console.log('error_synchronize')
      alert(I18n.t('global.ajax_failed'))
    success: (data, textStatus, jqXHR) ->
      console.log('success')

  event.preventDefault()