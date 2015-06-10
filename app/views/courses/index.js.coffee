$("#filterrific_results").html("<%= escape_javascript(render(partial: 'courses/courses_list', locals: { courses: @courses })) %>")

set_filter_options_to_param()

$("#filterrific_results").append("<%= escape_javascript (render( (partial: 'courses/courses_list', locals: { courses: @courses })) ) %>");
