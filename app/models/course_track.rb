class CourseTrack < ActiveRecord::Base
  belongs_to :track_type, class_name: 'CourseTrackType', foreign_key: 'course_track_type_id'
  belongs_to :course

  validate :costs_completeness


  private

  def costs_completeness
    if (costs && costs_currency) || (costs.nil? && costs_currency.nil?)
      return true
    else
      return false
    end
  end
end