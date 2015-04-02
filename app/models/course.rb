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

  before_save :check_and_update_duration
  after_save :create_and_update_course_connections
  before_destroy :delete_dangling_course_connections


  private
  def check_and_update_duration
    if self.end_date && self.start_date
      if self.calculated_duration_in_days != (self.end_date.to_date - self.start_date.to_date).to_i
        self.calculated_duration_in_days = (self.end_date.to_date - self.start_date.to_date).to_i
        self.save
      end
    end
  end

  def delete_dangling_course_connections
    check_and_delete_previous_course_connection
    check_and_delete_following_course_connection
  end

  def check_and_delete_previous_course_connection
    if self.previous_iteration_id
      previous_course = Course.find(self.previous_iteration_id)
      if previous_course.following_iteration_id == self.id
        previous_course.following_iteration_id = nil
        previous_course.save
      end
    end
  end

  def check_and_delete_following_course_connection
    if self.following_iteration_id
      following_course = Course.find(self.following_iteration_id)
      if following_course.previous_iteration_id == self.id
        following_course.previous_iteration_id = nil
        following_course.save
      end
    end
  end

  def create_and_update_course_connections
    check_and_update_previous_course_connection
    check_and_update_following_course_connection
  end

  def check_and_update_previous_course_connection
    if self.previous_iteration_id
      previous_course = Course.find(self.previous_iteration_id)
      if previous_course.following_iteration_id != self.id
        previous_course.following_iteration_id = self.id
        previous_course.save
      end
    end
  end

  def check_and_update_following_course_connection
    if self.following_iteration_id
      following_course = Course.find(self.following_iteration_id)
      if following_course.previous_iteration_id != self.id
        following_course.previous_iteration_id = self.id
        following_course.save
      end
    end
  end

end
