ready = ->
  $('.rate-evaluation-link').on 'click', (event) -> sendEvaluationRating(event)

$(document).ready(ready)

sendEvaluationRating = (event) ->
  evaluation_id = $(event.target).data('evaluation_id')
  helpful = $(event.target).data('helpful')
  url = "/evaluations/#{evaluation_id}/process_evaluation_rating.json"
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
      $("div.was-helpful-evaluation-#{evaluation_id}").html(I18n.t('evaluations.thanks_for_feedback'))
      $("div.was-helpful-evaluation-#{evaluation_id}").addClass("evaluation-rating-reply")
  event.preventDefault()
