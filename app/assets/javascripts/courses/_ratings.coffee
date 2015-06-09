ready = ->
  $('.rate-evaluation-link').on 'click', (event) -> sendEvaluationRating(event)

$(document).ready(ready)

sendEvaluationRating = (event) ->
  console.log('got a request')
  evaluation_id = $(event.target).data('evaluation_id')
  helpful = $(event.target).data('helpful')
  url = "/evaluations/#{evaluation_id}/processEvaluationRating.json"
  data =
    helpful: helpful
  $.ajax
    url: url
    method: 'POST'
    data: data
    error: (jqXHR, textStatus, errorThrown) ->
      console.log('error_status')
      alert(I18n.t('global.ajax_failed'))
    success: (data, textStatus, jqXHR) ->
      console.log('success')
  event.preventDefault()
