
ready = ->
  $('#load-account-settings-button').on 'click', (event) -> loadAccountSettings(event)
  $('#load-mooc-provider-settings-button').on 'click', (event) -> loadMoocProviderSettings(event)
  $('#sync-user-mooc_provider-connection-button').on 'click', (event) -> synchronizeUserMoocProviderConnection(event)
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
  password = $("#input-password-#{mooc_provider}").val()
  url = "/users/#{user_id}/set_mooc_provider_connection.json"
  $.ajax
    url: url
    method: 'GET'
    data:{email:email, password: password, mooc_provider:mooc_provider}
    error: (jqXHR, textStatus, errorThrown) ->
      console.log('error_synchronize')
      alert(I18n.t('global.ajax_failed'))
    success: (data, textStatus, jqXHR) ->
      console.log(data.status)
      if data.status == true
        $("#panel-#{mooc_provider}").removeClass("panel-default")
        $("#panel-#{mooc_provider}").removeClass("panel-danger")
        $("#panel-#{mooc_provider}").addClass("panel-success")
        $("#div-error-#{mooc_provider}").text("")
      else
        $("#div-error-#{mooc_provider}").text("Error!")
  event.preventDefault()

revokeUserMoocProviderConnection = (event) ->
  button = $(event.target)
  user_id = button.data('user_id')
  mooc_provider = button.data('mooc_provider')
  url = "/users/#{user_id}/revoke_mooc_provider_connection.json"
  $.ajax
    url: url
    method: 'GET'
    data:{mooc_provider:mooc_provider}
    error: (jqXHR, textStatus, errorThrown) ->
      console.log('error_synchronize')
      alert(I18n.t('global.ajax_failed'))
    success: (data, textStatus, jqXHR) ->
      console.log(data.status)
      if data.status == true
        $("#panel-#{mooc_provider}").removeClass("panel-success")
        $("#panel-#{mooc_provider}").removeClass("panel-danger")
        $("#panel-#{mooc_provider}").addClass("panel-default")
        $("#div-error-#{mooc_provider}").text("")
      else
        $("#div-error-#{mooc_provider}").text("Error!")
  event.preventDefault()

@bindClickEvents = () ->
  $('button[id="sync-user-mooc_provider-connection-button"]').on 'click', (event) -> synchronizeUserMoocProviderConnection(event)
  $('button[id="revoke-user-mooc_provider-connection-button"]').on 'click', (event) -> revokeUserMoocProviderConnection(event)
