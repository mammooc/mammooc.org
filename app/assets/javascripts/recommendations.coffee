# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

group_ids = []
groups_autocomplete = []
users_autocomplete = []
courses_autocomplete = []

generate_groups_autocomplete = () ->
  get_my_groups()
  $("#recommendation_related_group_ids").tokenfield
    autocomplete:
      source: groups_autocomplete
      delay: 100
    showAutocompleteOnFocus: true
    delimiter: ' '

get_my_groups = () ->
  group_ids = []
  groups_autocomplete = []
  $.ajax
    url: '/groups.json'
    method: 'GET'
    async: false
    error: (jqXHR, textStatus, errorThrown) ->
      console.log('error_get_my_groups')
    success: (data, textStatus, jqXHR) ->
      console.log('success_get_my_groups')
      for group in data
        group_ids.push(group.id)
        groups_autocomplete.push({ value: group.id, label: group.name })


generate_users_autocomplete = () ->
  users_autocomplete = []
  get_my_groups()
  for group_id in group_ids
    $.ajax
      url: '/groups/' + group_id + '/members.json'
      async: false
      method: 'GET'
      error: (jqXHR, textStatus, errorThrown) ->
        console.log('users error')
      success: (data, textStatus, jqXHR) ->
        console.log('users success')
        for user in data.group_members
          users_autocomplete.push({ value: user.id, label: user.first_name + ' ' + user.last_name })

  $("#recommendation_related_user_ids").tokenfield
    autocomplete:
      source: users_autocomplete
      delay: 100
    showAutocompleteOnFocus: true
    delimiter: ' '

generate_course_autocomplete = () ->
  courses_autocomplete = []
  $.ajax
    url: '/courses.json'
    async: false
    method: 'GET'
    error: (jqXHR, textStatus, errorThrown) ->
      console.log('courses error')
    success: (data, textStatus, jqXHR) ->
      console.log('courses success')
      for course in data
        courses_autocomplete.push({ label: course.name, value: course.id })
  $('#recommendation_course_id').tokenfield
    autocomplete:
      source: courses_autocomplete
      delay: 100
    showAutocompleteOnFocus: true
    delimiter: ' '
    limit: 1

@recommendationNewParameters = () ->
  generate_course_autocomplete()
  generate_groups_autocomplete()
  generate_users_autocomplete()
  params = getParams()
  if 'course_id' of params
    course_id = params['course_id']
    $.ajax
      url: '/courses/' + course_id + '.json'
      method: 'GET'
      error: (jqXHR, textStatus, errorThrown) ->
        console.log('course id error')
      success: (data, textStatus, jqXHR) ->
        console.log('course id success')
        course_name = data.name
        $('#recommendation_course_id').tokenfield('setTokens', [{value: course_id, label: course_name}])
  else
    console.log('false')