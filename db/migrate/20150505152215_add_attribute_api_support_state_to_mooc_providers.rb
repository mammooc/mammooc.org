class AddAttributeApiSupportStateToMoocProviders < ActiveRecord::Migration
  def change
    add_column(:mooc_providers, :api_support_state, :integer)
  end
end
