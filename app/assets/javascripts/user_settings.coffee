
ready = ->
  $('#load-account-settings-button').on 'click', (event) -> loadAccountSettings(event)
  $('#load-mooc-provider-settings-button').on 'click', (event) -> loadMoocProviderSettings(event)
  $('#load-privacy-settings-button').on 'click', (event) -> loadPrivacySettings(event)

  $('button.setting-add-button').on 'click', (event) -> addSetting(event)
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

loadPrivacySettings = (event) ->
  button = $(event.target)
  user_id = button.data('user_id')
  url = "/users/#{user_id}/privacy_settings.json"
  $.ajax
    url: url
    method: 'GET'
    error: (jqXHR, textStatus, errorThrown) ->
      console.log('error_synchronize')
      alert(I18n.t('global.ajax_failed'))
    success: (data, textStatus, jqXHR) ->
      $("div.settings-container").html(data.partial)
      window.history.pushState({id: 'set_privacy_subsite'}, '', 'settings?subsite=privacy');
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

addSetting = (event) ->
  button = if (event.target.nodeName == 'SPAN') then $(event.target.parentElement) else $(event.target)
  list_id = button.data('list-id')
  list = $("##{list_id}")

  ok_button = $('<button></button>')
                .addClass('btn btn-default')
                .append($('<span></span>').addClass('glyphicon glyphicon-ok'))
  ok_button.on 'click', (event) ->
    event.preventDefault()
    input = $(this).parent().find('input')
    if input.val() != ''
      existing_ids = []
      $.each $(this).closest('ul').children(), (_, li) ->
        existing_ids.push $(li).data('id') if $(li).data('id')

    else
      subject = list.data('key').slice(0, -1)
      alert(I18n.t('flash.error.settings.input_empty', subject: I18n.t("flash.error.settings.#{subject}")))

  cancel_button = $('<button></button>')
                    .addClass('btn btn-default')
                    .append($('<span></span>').addClass('glyphicon glyphicon-remove'))
  cancel_button.on 'click', (event) ->
    event.preventDefault()
    form_item.remove()

  input = $('<input></input>').attr('type', 'text').addClass('form-control')
  input_source_url = switch list.data('key')
    when 'groups' then '/groups.json'
    when 'users' then 'dontknowyet'

  input.autocomplete
    minLength: 2
    source: (request, response) ->
      $.ajax
        url: input_source_url
        dataType: "json"
        data:
          q: request.term
        error: (jqXHR, textStatus, errorThrown) ->
          alert(I18n.t('global.ajax_failed'))
        success: (data, textStatus, jqXHR) ->
          results = []
          for item in data
            results.push({ label: item.name, value: item.id })
          response(results)
    delay: 100
    autoFocus: true



  form_item = $('<li></li>').addClass('list-group-item').append(
    $('<form></form>').addClass('form-inline')
      .append($('<div></div>').addClass('form-group')
        .append(input))
      .append(ok_button)
      .append(cancel_button))
  list.prepend(form_item)

@bindClickEvents = () ->
  $('button[id="sync-naive-user-mooc_provider-connection-button"]').on 'click', (event) ->
    synchronizeNaiveUserMoocProviderConnection(event)
  $('button[id="revoke-naive-user-mooc_provider-connection-button"]').on 'click', (event) ->
    revokeNaiveUserMoocProviderConnection(event)
  $('button.setting-add-button').on 'click', (event) -> addSetting(event)
