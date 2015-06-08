# -*- encoding : utf-8 -*-
module ApplicationHelper
  def resource_class
    devise_mapping.to
  end

  def easy_id_link
    tc_token_url_escaped = CGI.escape "https://ausweislogin.de/easyID/?target=#{easy_id_url}"
    "http://127.0.0.1:24727/eID-Client?tcTokenURL=#{tc_token_url_escaped}"
  end
end
