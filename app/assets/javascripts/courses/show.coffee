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
$(document).on('page:load', ready)

removeActiveClass = (event) ->
  targetId = $(event.currentTarget)[0].id + '-link'
  $('#' + targetId).children('.entry').removeClass('active')

addActiveClass = (event) ->
  targetId = $(event.currentTarget)[0].id + '-link'
  $('#' + targetId).children('.entry').addClass('active')

toggleAccordion = (event) ->
  $('.collapse').collapse('hide')

enrollCourse = (event) ->
  console.log($(event.target))
  course_id = $(event.target).data('course-id')
  url = '/courses/' + course_id + '/enroll_course.json'
  $.ajax
    url: url
    method: 'GET'
    error: (jqXHR, textStatus, errorThrown) ->
      console.log('error_status')
    success: (data, textStatus, jqXHR) ->
      console.log('success_status')
      if data.status == true
        $(event.target).parent().off("click","#enroll-course-link")
        $(event.target).text(I18n.t('courses.unenroll_course'))
        $(event.target).parent().attr("id","unenroll-course-link")
        $(event.target).parent().on("click","#unenroll-course-link",unenrollCourse)

  event.preventDefault()

unenrollCourse = (event) ->
  console.log($(event.target))
  course_id = $(event.target).data('course-id')
  url = '/courses/' + course_id + '/unenroll_course.json'
  $.ajax
    url: url
    method: 'GET'
    error: (jqXHR, textStatus, errorThrown) ->
      console.log('error_status')
    success: (data, textStatus, jqXHR) ->
      console.log('success_status')
      if data.status == true
        $(event.target).parent().off("click","#unenroll-course-link")
        $(event.target).text(I18n.t('courses.enroll_course'))
        $(event.target).parent().attr("id","enroll-course-link")
        $(event.target).parent().on("click","#enroll-course-link",enrollCourse)

  event.preventDefault()
