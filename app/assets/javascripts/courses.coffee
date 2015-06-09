# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

@set_filter_options_to_param = () ->
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

$(document).ready set_filter_options_to_param
