$("#filterrific_results").html("<%= escape_javascript(render(partial: 'courses/courses_list', locals: { courses: @courses })) %>")

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
