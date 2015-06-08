# -*- encoding : utf-8 -*-
module ApplicationHelper
  def resource_class
    devise_mapping.to
  end
end
