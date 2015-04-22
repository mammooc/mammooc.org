ready = ->
  $('.collapse').collapse({toggle: false})
  $('.collapse').on('show.bs.collapse', addActiveClass)
  $('.collapse').on('hidden.bs.collapse', removeActiveClass)
  $('#recommend-course-link').click(toggleAccordion)
  $('#rate-course-link').click(toggleAccordion)

  content_height = $('#course-description').children().find('.content').outerHeight()
  title_height = $('#course-description').children().find('.title').outerHeight()
  if content_height > ($('#course-description').height() - title_height)
    $('#course-description-show-more.show-more').show()
                                                .click(showMore)
  return

$(document).ready(ready)
$(document).on('page:load', ready)

removeActiveClass = (event) ->
  targetId = $(event.currentTarget)[0].id + '-link'
  $('#' + targetId).removeClass('entry-active')

addActiveClass = (event) ->
  targetId = $(event.currentTarget)[0].id + '-link'
  $('#' + targetId).addClass('entry-active')

toggleAccordion = (event) ->
  $('.collapse').collapse('hide')

showMore = () ->
  $('#course-description-show-more').parent().css('max-height', 'none')
  $('#course-description-show-more').removeClass('show-more')
  $('#course-description-show-more').addClass('show-less')
  $('#course-description-show-more').text(I18n.t('global.show_less'))
  $('#course-description-show-more.show-less').click(showLess)

showLess = () ->
  $('.show-less').parent().css('max-height', '250px')
  $('.show-less').parent().children('a').addClass('show-more')
  $('#course-description-show-more').text(I18n.t('global.show_more'))
  $('.show-more').parent().children('a').removeClass('show-less')
  $('#course-description-show-more.show-more').click(showMore)