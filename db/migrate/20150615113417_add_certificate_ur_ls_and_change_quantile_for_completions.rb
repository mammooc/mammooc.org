class AddCertificateUrLsAndChangeQuantileForCompletions < ActiveRecord::Migration
  def change
    remove_column :certificates, :file_id
    add_column :certificates, :download_url, :string, null: false
    add_column :certificates, :verification_url, :string, null: true, default: nil
    add_column :certificates, :document_type, :string

    remove_column :completions, :permissions
    remove_column :completions, :date
    rename_column :completions, :position_in_course, :quantile
    change_column :completions, :quantile, :float, null: true, default: nil
    rename_column :completions, :points, :points_achieved
    add_column :completions, :provider_percentage, :float, null: true, default: nil
  end
end
