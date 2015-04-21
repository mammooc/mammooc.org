ready = ->
  $('.collapse').collapse({toggle: false})
  $('.collapse').on('show.bs.collapse', addActiveClass)
  $('.collapse').on('hidden.bs.collapse', removeActiveClass)
  $('#recommend-course-link').click(toggleAccordion)
  $('#rate-course-link').click(toggleAccordion)
  $('#showmore.show-more').click(showMore)
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

showMore = () ->
  $('#showmore').parent().css('height', 'auto')
  $('#showmore').removeClass('show-more')
  $('#showmore').addClass('show-less')
  $('#showmore.show-less').click(showLess)

showLess = () ->
  $('.show-less').parent().css('height', '250px')
  $('.show-less').parent().children('a').addClass('show-more')
  $('.show-more').parent().children('a').removeClass('show-less')
  $('#showmore.show-more').click(showMore)