class Course < ActiveRecord::Base
  filterrific available_filters: %w[with_start_date_gte with_end_date_lt with_language]

  belongs_to :mooc_provider
  belongs_to :course_result
  has_many :courses
  has_many :recommendations, dependent: :destroy
  has_many :completions
  has_and_belongs_to_many :users
  has_many :course_requests
  has_many :progresses
  has_many :bookmarks
  has_many :evaluations
  has_many :course_assignments
  has_many :user_assignments
  has_many :tracks, class_name: 'CourseTrack', dependent: :destroy

  validates :tracks, length: {minimum: 1}

  before_save :check_and_update_duration
  after_save :create_and_update_course_connections
  before_destroy :delete_dangling_course_connections

  #possible errors because some courses don't have start/end-dates set.
  scope :with_start_date_gte, lambda { |reference_time| where('courses.start_date IS NOT NULL AND (courses.start_date >= ?) ', DateTime.parse(reference_time).strftime('%Y-%m-%d %H:%M:%S.%6N')) }

  scope :with_end_date_lt, lambda { |reference_time| where('courses.end_date IS NOT NULL AND (courses.end_date <= ?) ', DateTime.parse(reference_time).strftime('%Y-%m-%d %H:%M:%S.%6N'))}

  scope :with_language, lambda { |reference_language| where('courses.language IS NOT NULL AND (courses.language = ? OR courses.language LIKE ?)', reference_language, "#{reference_language}-%") }

  def self.options_for_languages

    [[I18n.t('language.english'), 'en'],
     [I18n.t('language.german'), 'de'],
     [I18n.t('language.spanish'), 'es'],
     [I18n.t('language.french'), 'fr'],
     [I18n.t('language.chinese'), 'zh'],
     [I18n.t('language.portuguese'), 'pt'],
     [I18n.t('language.russian'), 'ru'],
     [I18n.t('language.swedish'), 'sv'],
     [I18n.t('language.hebrew'), 'he'],
     [I18n.t('language.italian'), 'it'],
     [I18n.t('language.arabic'), 'ar'],
    ]

  end

  self.per_page = 10

  def self.get_course_id_by_mooc_provider_id_and_provider_course_id(mooc_provider_id, provider_course_id)
    course = Course.where(provider_course_id: provider_course_id, mooc_provider_id: mooc_provider_id).first
    if course.present?
      return course.id
    else
      return nil
    end
  end

  private

  def check_and_update_duration
    if self.end_date && self.start_date
      if start_date_is_before_end_date
        if self.calculated_duration_in_days != (self.end_date.to_date - self.start_date.to_date).to_i
          self.calculated_duration_in_days = (self.end_date.to_date - self.start_date.to_date).to_i
          self.save
        end
      else
        self.end_date = nil
      end
    end
  end

  def start_date_is_before_end_date
    self.start_date <= self.end_date ? (return true) : (return false)
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
