ready = ->
  $('.collapse').collapse({toggle: false})
  $('.collapse').on('show.bs.collapse', addActiveClass)
  $('.collapse').on('hidden.bs.collapse', removeActiveClass)
  $('#recommend-course-link').click(toggleAccordion)
  $('#rate-course-link').click(toggleAccordion)
  return

$(document).ready(ready)
$(document).on('page:load', ready)

removeActiveClass = (event) ->
  targetId = $(event.currentTarget)[0].id + '-link'
  $('#' + targetId).children('.entry').removeClass('entry-active')

addActiveClass = (event) ->
  targetId = $(event.currentTarget)[0].id + '-link'
  $('#' + targetId).children('.entry').addClass('entry-active')

toggleAccordion = (event) ->
  $('.collapse').collapse('hide')
  