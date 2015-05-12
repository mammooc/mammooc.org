# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

@set_filter_options_to_param = () ->
  if location.pathname == '/courses'
    $.ajax
      url: 'courses/get_filter_options.json'
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

$(document).ready set_filter_options_to_param
