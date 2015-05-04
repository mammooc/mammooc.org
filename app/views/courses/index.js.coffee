$("#filterrific_results").html("<%= escape_javascript(render(partial: 'courses/courses_list', locals: { courses: @courses })) %>")
