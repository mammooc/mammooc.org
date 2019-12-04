# frozen_string_literal: true

module ApplicationHelper
  def resource_class
    devise_mapping.to
  end
end
