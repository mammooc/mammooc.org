ready = ->
  $('#course-list-view-button').on 'click', () -> change_view_to_list()
  $('#course-tile-view-button').on 'click', () -> change_view_to_tile()

$(document).ready(ready)


change_view_to_list = () ->
  $('div.courses-tile-wrapper').attr('class', 'courses-list-wrapper');
  $('div.course-tile-status').addClass('course-list-status');
  $('div.course-tile-status').removeClass('course-tile-status');

  # set cookie to remember state
  now = new Date();
  time = now.getTime();
  time += 3600 * 1000 * 24 * 365 * 10;
  now.setTime(time);
  document.cookie = 'view_status=list; expires=' + now.toUTCString() + ';';

change_view_to_tile = () ->
  $('div.courses-list-wrapper').attr('class', 'courses-tile-wrapper');
  $('div.course-list-status').addClass('course-tile-status');
  $('div.course-list-status').removeClass('course-list-status');

  # set cookie to remember state
  now = new Date();
  time = now.getTime();
  time += 3600 * 1000 * 24 * 365 * 10;
  now.setTime(time);
  document.cookie = 'view_status=tile; expires=' + now.toUTCString() + ';';
