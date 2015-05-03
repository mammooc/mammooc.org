
ready = ->
  $('#load-account-settings-button').on 'click', (event) -> loadAccountSettings(event)
  $('#load-mooc-provider-settings-button').on 'click', (event) -> loadMoocProviderSettings(event)
  $('#sync-user-mooc_provider-connection-button'). on 'click', (event) -> synchronizeUserMoocProviderConnection(event)
  return

$(document).ready(ready)

loadAccountSettings = (event) ->
  button = $(event.target)
  user_id = button.data('user_id')
  url = "/users/#{user_id}/account_settings.json"
  $.ajax
    url: url
    method: 'GET'
    error: (jqXHR, textStatus, errorThrown) ->
      console.log('error_synchronize')
      alert(I18n.t('global.ajax_failed'))
    success: (data, textStatus, jqXHR) ->
      $("div.settings-container").html(data.partial)
  event.preventDefault()

loadMoocProviderSettings = (event) ->
  button = $(event.target)
  user_id = button.data('user_id')
  url = "/users/#{user_id}/mooc_provider_settings.json"
  $.ajax
    url: url
    method: 'GET'
    error: (jqXHR, textStatus, errorThrown) ->
      console.log('error_synchronize')
      alert(I18n.t('global.ajax_failed'))
    success: (data, textStatus, jqXHR) ->
      $("div.settings-container").html(data.partial)
  event.preventDefault()

synchronizeUserMoocProviderConnection = (event) ->
  button = $(event.target)
  user_id = button.data('user_id')
  mooc_provider = button.data('mooc_provider')
  email = $("#input-email-#{mooc_provider}").val()
#  $.ajax
#    url: url
#    method: 'GET'
#    error: (jqXHR, textStatus, errorThrown) ->
#      console.log('error_synchronize')
#      alert(I18n.t('global.ajax_failed'))
#    success: (data, textStatus, jqXHR) ->
#      $("div.settings-container").html(data.partial)
  console.log(mooc_provider)
  console.log(user_id)
  console.log(email)
  event.preventDefault()

@bindClickEvents = () ->
  $('button[id="sync-user-mooc_provider-connection-button"]').on 'click', (event) -> synchronizeUserMoocProviderConnection(event)
