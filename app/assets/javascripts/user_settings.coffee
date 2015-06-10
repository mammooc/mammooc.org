
ready = ->
  $('#load-account-settings-button').on 'click', (event) -> loadAccountSettings(event)
  $('#load-mooc-provider-settings-button').on 'click', (event) -> loadMoocProviderSettings(event)
  $('#add_new_email_field').on 'click', (event) -> addNewEmailField(event)
  return

$(document).ready(ready)

addNewEmailField = (event) ->
  event.preventDefault()
  table = document.getElementById('table_for_user_emails')
  index = table.rows.length
  new_row = table.insertRow(index-1)
  cell_address = new_row.insertCell(0)
  cell_primary = new_row.insertCell(1)
  html_for_address_field = "class='form-control' autofocus='autofocus' type='email' name='user[user_email][address_#{index-1}]' id='user_user_email_address_#{index-1}'"
  cell_address.innerHTML = "<input #{html_for_address_field}>"
  html_for_primary_field = "type='radio' name='user[user_email][is_primary]' id='user_user_email_is_primary_#{index-1}'"
  cell_primary.innerHTML = "<input #{html_for_primary_field}>"
  $('#user_index').val(index-1)


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
      window.history.pushState({id: 'set_account_subsite'}, '', 'settings?subsite=account');
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
      window.history.pushState({id: 'set_mooc_provider_subsite'}, '', 'settings?subsite=mooc_provider');
  event.preventDefault()

synchronizeNaiveUserMoocProviderConnection = (event) ->
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
      if data.status == true
        $("div.settings-container").html(data.partial)
      else
        $("#div-error-#{mooc_provider}").text("Error!")
  event.preventDefault()

revokeNaiveUserMoocProviderConnection = (event) ->
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
      if data.status == true
        $("div.settings-container").html(data.partial)
      else
        $("#div-error-#{mooc_provider}").text("Error!")
  event.preventDefault()

@bindClickEvents = () ->
  $('button[id="sync-naive-user-mooc_provider-connection-button"]').on 'click', (event) ->
    synchronizeNaiveUserMoocProviderConnection(event)
  $('button[id="revoke-naive-user-mooc_provider-connection-button"]').on 'click', (event) ->
    revokeNaiveUserMoocProviderConnection(event)
