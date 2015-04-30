# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$("#filterrific_results").html("<%= render partial: 'courses/courses_list', locals: { courses: @courses }  %>")
$('.js-datepicker').datepicker({format: 'dd-mm-yyyy'})
