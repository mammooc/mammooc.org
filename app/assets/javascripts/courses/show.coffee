ready = ->
  $('.collapse').collapse({toggle: false})
  $('.collapse').on('show.bs.collapse', addActiveClass)
  $('.collapse').on('hidden.bs.collapse', removeActiveClass)
  $('#recommend-course-link').click(toggleAccordion)
  $('#rate-course-link').click(toggleAccordion)
  $('#enroll-course-link').on 'click', (event) -> enrollCourse(event)
  $('#unenroll-course-link').on 'click', (event) -> unenrollCourse(event)
  return

$(document).ready(ready)

removeActiveClass = (event) ->
  targetId = $(event.currentTarget)[0].id + '-link'
  $('#' + targetId).children('.entry').removeClass('active')

addActiveClass = (event) ->
  targetId = $(event.currentTarget)[0].id + '-link'
  $('#' + targetId).children('.entry').addClass('active')

toggleAccordion = (event) ->
  $('.collapse').collapse('hide')

enrollCourse = (event) ->
  course_id = $(event.target).data('course-id')
  url = "/courses/#{course_id}/enroll_course.json"
  $.ajax
    url: url
    method: 'GET'
    error: (jqXHR, textStatus, errorThrown) ->
      console.log('error_status')
      alert(I18n.t('global.ajax_failed'))
    success: (data, textStatus, jqXHR) ->
      if data.status == true
        $(event.target).text(I18n.t('courses.unenroll_course'))
                       .parent().unbind('click')
                                .attr('id','unenroll-course-link')
                                .on 'click', (event) -> unenrollCourse(event)
      else
        alert(I18n.t('courses.enrollment_error'))
  event.preventDefault()

unenrollCourse = (event) ->
  course_id = $(event.target).data('course-id')
  url = "/courses/#{course_id}/unenroll_course.json"
  $.ajax
    url: url
    method: 'GET'
    error: (jqXHR, textStatus, errorThrown) ->
      console.log('error_status')
      alert(I18n.t('global.ajax_failed'))
    success: (data, textStatus, jqXHR) ->
      if data.status == true
        $(event.target).text(I18n.t('courses.enroll_course'))
                       .parent().unbind('click')
                                .attr('id','enroll-course-link')
                                .on 'click', (event) -> enrollCourse(event)
      else
        alert(I18n.t('courses.unenrollment_error'))
  event.preventDefault()
