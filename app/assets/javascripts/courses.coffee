# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

@current_page = 1
@total_entries = 0

@set_filter_options_to_param = (callback) ->
  if location.pathname == '/courses'
    $.ajax
      url: 'courses/filter_options.json'
      method: 'GET'
      error: (jqXHR, textStatus, errorThrown) ->
        alert(I18n.t('global.ajax_failed'))
      success: (data, textStatus, jqXHR) ->
        if data.filter_options.length > 0
          _url = location.href
          if _url.indexOf('?') == -1
            _url += '?'
            _url += data.filter_options
          else if _url.indexOf('filterrific') == -1
            _url += '&'
            _url += data.filter_options
          else
            if _url.search(/filterrific.*&(?!filterrific)/g) == -1
              _url = _url.replace(/filterrific.*/g, data.filter_options)
            else
              _url = _url.replace(/filterrific.*?(?=&[^filterrific])/g, data.filter_options)
          $('.dropdown-language-entry').each (_index, language_entry) ->
            if _url.search(/(?!with_)language=(.{2})/) != -1
              link = _url.replace(/(?!with_)language=(.{2})/, "language=#{$(language_entry).data('language')}")
            else
              link = "#{_url}&language=#{$(language_entry).data('language')}"
            $(language_entry).attr('href', link)
          history.pushState({},'filter_state', _url)
          if (callback)
            callback()

@copySelectOption = (fromId, toId) ->
  _options = $('#' + fromId + " > option").clone()
  $('#' + toId).append(_options)
  $('#' + toId).on "change": (event) ->
    $('#' + fromId).val($('#' + toId).val())
    $('#' + fromId).change()

@copyInputField = (fromId, toId) ->
  $('#' + toId).val($('#' + fromId).val())
  $('#' + toId).on "change input": (event) ->
    $('#' + fromId).val($('#' + toId).val())
    $('#' + fromId).change()

@load_more = () ->
  #  Retrieve original URL parameters and only replace page attribute with the next possible
  set_filter_options_to_param(()->
    $('.loading_spinner').css('visibility', 'visible')
    current_page++

    refresh_load_button()

    url = '/courses/load_more'
    url += if location.search.length > 0 then location.search + '&page=' + current_page else '?page=' + current_page
    $.get url, (data) ->
      $('.courses-wrapper').append($(data))
      $('.loading_spinner').css('visibility', 'hidden')
      prepare_bookmark_events()
  )

@refresh_load_button = ()->
  if @total_entries > 20 * current_page
    $('#loadMore').show();
  else
    $('#loadMore').hide();


@prepare_bookmark_events = () ->
  $('.bookmark-icon-o').unbind('click')
                       .on 'click', (event) -> addToWishlist(event)
  $('.bookmark-icon').unbind('click')
                     .on 'click', (event) -> removeFromWishlist(event)

@toggle_title = (target) ->
  toggle_title = target.attr('data-original-title')
  target.attr('data-original-title', target.attr('toggle-title'))
  .attr('toggle-title', toggle_title)

@addToWishlist = (event) ->
  console.log('Click event fired (add)')
  target = $(event.delegateTarget)
  current_course_id = target.data('course_id')
  current_user_id = target.data('user_id')
  url = "/bookmarks"
  data =
    bookmark :
      course_id : current_course_id
      user_id : current_user_id
  console.log(data)
  $.ajax
    url: url
    data: data
    method: 'POST'
    error: (jqXHR, textStatus, errorThrown) ->
      alert(I18n.t('global.ajax_failed'))
    success: (data, textStatus, jqXHR) ->
      toggle_title(target.parent())
      target.unbind('click')
            .removeClass('bookmark-icon-o').addClass('bookmark-icon')
            .children('i').removeClass('action-icon-gray').addClass('action-icon-green')
      target.on 'click', (event) -> removeFromWishlist(event)
  event.preventDefault()

@removeFromWishlist = (event) ->
  target = $(event.delegateTarget)
  current_course_id = target.data('course_id')
  current_user_id = target.data('user_id')
  url = "/bookmarks/delete"
  data =
    course_id : current_course_id
    user_id : current_user_id

  $.ajax
    url: url
    data: data
    method: 'POST'
    error: (jqXHR, textStatus, errorThrown) ->
      alert(I18n.t('global.ajax_failed'))
    success: (data, textStatus, jqXHR) ->
      toggle_title(target.parent())
      target.unbind('click')
            .removeClass('bookmark-icon').addClass('bookmark-icon-o')
            .children('i').removeClass('action-icon-green').addClass('action-icon-gray')
      target.on 'click', (event) -> addToWishlist(event)
  event.preventDefault()

@prepare_enrollment_events = () ->
  $('.enroll-icon').on 'click', (event) -> addToEnrollments(event)
  $('.unenroll-icon').on 'click', (event) -> removeFromEnrollments(event)

@addToEnrollments = (event) ->
  target = $(event.delegateTarget)
  course_id = target.data('course_id')
  url = "/courses/#{course_id}/enroll_course.json"
  $.ajax
    url: url
    method: 'GET'
    error: (jqXHR, textStatus, errorThrown) ->
      console.log("error")
      alert(I18n.t('global.ajax_failed'))
    success: (data, textStatus, jqXHR) ->
      console.log('success')
      if data.status == true
        toggle_title(target.parent())
        target.unbind('click')
            .removeClass('enroll-icon').addClass('unenroll-icon')
            .children('i').removeClass('action-icon-gray').addClass('action-icon-green')
        target.on 'click', (event) -> removeFromEnrollments(event)
  event.preventDefault()

@removeFromEnrollments = (event) ->
  target = $(event.delegateTarget)
  course_id = target.data('course_id')
  url = "/courses/#{course_id}/unenroll_course.json"
  $.ajax
    url: url
    method: 'GET'
    error: (jqXHR, textStatus, errorThrown) ->
      alert(I18n.t('global.ajax_failed'))
    success: (data, textStatus, jqXHR) ->
      toggle_title(target.parent())
      target.unbind('click')
            .removeClass('unenroll-icon').addClass('enroll-icon')
            .children('i').removeClass('action-icon-green').addClass('action-icon-gray')
      target.on 'click', (event) -> addToEnrollments(event)
  event.preventDefault()

$ =>
  console.log("DOM is ready")
  set_filter_options_to_param
  copySelectOption("filterrific_sorted_by", "new_sort")
  copyInputField("filterrific_search_query", "new_search")
  @total_entries = parseInt($('#result_count').text())
  prepare_bookmark_events()
  prepare_enrollment_events()
