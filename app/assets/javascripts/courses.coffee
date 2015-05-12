# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

set_filter_options_to_param = () ->
  if location.pathname == '/courses'
    $.ajax
      url: 'courses/get_filter_options.json'
      method: 'GET'
      error: (jqXHR, textStatus, errorThrown) ->
        console.log('error filter options')
      success: (data, textStatus, jqXHR) ->
        console.log('success filter options')
        console.log(data.filter_options)
        _url = location.pathname
        _url += '?'
        _url += data.filter_options
        history.pushState({},'test', _url)

$(document).ready set_filter_options_to_param
