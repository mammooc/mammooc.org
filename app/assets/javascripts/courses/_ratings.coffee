ready = ->
  $('#submit-rating-button').on 'click', (event) -> sendCourseReview(event)
  return

$(document).ready(ready)

sendCourseReview = (event) ->
  button = $(event.target)
  course_id = button.data('course_id')
  if typeof $("#rating-input").rating('rate') is 'object'
    rating_input = 0
  else
    rating_input = $("#rating-input").rating('rate')
  rating_textarea = $("#rating-textarea").val()
  if typeof $("#course-status-selector .active").data("value") is 'undefined'
    course_status = 0
  else
    course_status = $("#course-status-selector .active").data("value")
  rate_anonymously = $("#rate-anonymously-checkbox").is(':checked')
  data =
    rating : rating_input
    rating_textarea : rating_textarea
    course_status : course_status
    rate_anonymously : rate_anonymously
  url = "/courses/#{course_id}/send_evaluation.json"
  $.ajax
    url: url,
    data: data,
    method: 'POST',
    error: (jqXHR, textStatus, errorThrown) ->
      console.log('error_synchronize')
      alert(I18n.t('global.ajax_failed'))
    success: (data, textStatus, jqXHR) ->
      console.log('success')
  event.preventDefault()