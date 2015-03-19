class Course < ActiveRecord::Base
  belongs_to :mooc_provider
  belongs_to :course_result
  has_many :courses
  has_many :recommendations
  has_many :completions
  has_and_belongs_to_many :users
  has_many :course_requests
  has_many :progresses
  has_many :bookmarks
  has_many :evaluations
  has_many :course_assignments
  has_many :user_assignments

  before_save :checkAndUpdateDuration

  private
  def checkAndUpdateDuration
    if self.duration != (self.end_date.to_date - self.start_date.to_date).to_i
      self.duration = (self.end_date.to_date - self.start_date.to_date).to_i
      self.save
    end
  end

end
