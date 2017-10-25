# frozen_string_literal: true

class AddAttributeApiSupportStateToMoocProviders < ActiveRecord::Migration[4.2]
  def change
    add_column(:mooc_providers, :api_support_state, :integer)
  end
end
