ready = ->
  $('#sync-user-dates').on 'click', (event) -> synchronizeDatesIndexPage(event)
  return

$(document).ready(ready)

synchronizeDatesIndexPage = (event) ->
  url = "/user_dates/synchronize_dates_on_index_page.json"
  $.ajax
    url: url
    method: 'GET'
    error: (jqXHR, textStatus, errorThrown) ->
      console.log('error_synchronize_dates')
      alert(I18n.t('global.ajax_failed'))
    success: (data, textStatus, jqXHR) ->
      console.log('success_synchronize_dates')
      for mooc_provider, result of data.synchronization_state
        if result == false
          alert(I18n.t('dashboard.error_synchronize_dates', provider: mooc_provider))
        else if result != true
          window.location.replace(result)
      $("div.my-dates").html(data.partial)
  event.preventDefault()