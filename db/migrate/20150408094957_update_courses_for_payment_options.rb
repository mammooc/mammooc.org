# frozen_string_literal: true

class UpdateCoursesForPaymentOptions < ActiveRecord::Migration[4.2]
  def change
    change_table(:courses, bulk: true) do |t|
      t.boolean :has_paid_version
      t.boolean :has_free_version
    end
  end
end
