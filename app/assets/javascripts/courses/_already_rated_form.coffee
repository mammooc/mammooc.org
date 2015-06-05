toggleRatingForm = (event) ->
  $('.rating-form').toggle()

@bindToggleRatingFormClickEvent = () ->
  $('button[id="edit-rating-button"]').on 'click', (event) ->
    toggleRatingForm(event)
