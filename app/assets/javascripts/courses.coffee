# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

@current_page = 1
@total_entries = 0
#last_url = ""

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
          history.pushState({},'test', _url)
          if callback
            callback()

@load_more = () ->
  #  Retrieve original URL parameters and only replace page attribute with the next possible
  set_filter_options_to_param(()->
    $('.loading_spinner').show()
    current_page++ # = if location.search == last_url then current_page+1 else 2

    refresh_load_button()

    url = 'http://localhost:3003/courses/load_more'
    url += if location.search.length > 0 then location.search + '&page=' + current_page else '?page=' + current_page
    $.get url, (data) ->
      $('.courses-wrapper').append($(data))
      $('.loading_spinner').hide()
  )


@refresh_load_button = ()->
  if @total_entries > 10 * current_page
    $('#loadMore').show();
  else
    $('#loadMore').hide();

$ =>
  set_filter_options_to_param
  @total_entries = parseInt($('#result_count').text())
