# frozen_string_literal: true

class AddCertificateUrLsAndChangeQuantileForCompletions < ActiveRecord::Migration[4.2]
  def change
    change_table(:certificates, bulk: true) do |t|
      t.remove :file_id
      t.string :download_url, null: false
      t.string :verification_url, null: true, default: nil
      t.string :document_type
    end

    change_table(:completions, bulk: true) do |t|
      t.remove :permissions
      t.remove :date
      t.rename :position_in_course, :quantile
      t.change :quantile, :float, null: true, default: nil
      t.rename :points, :points_achieved
      t.float :provider_percentage, null: true, default: nil
    end
  end
end
