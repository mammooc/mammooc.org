# frozen_string_literal: true

class UpdateCoursesForPaymentOptions < ActiveRecord::Migration[4.2]
  def change
    add_column(:courses, :has_paid_version, :boolean)
    add_column(:courses, :has_free_version, :boolean)
  end
end
