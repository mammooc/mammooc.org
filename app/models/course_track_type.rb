# frozen_string_literal: true

class CourseTrackType < ActiveRecord::Base
  has_many :course_tracks, dependent: :destroy

  validates :title, :type_of_achievement, presence: true

  def self.options_for_select
    order('LOWER(title)').map {|track_type| [track_type.title, track_type.id] }
  end
end
