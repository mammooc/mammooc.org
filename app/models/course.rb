# frozen_string_literal: true

# rubocop:disable Style/Lambda

class Course < ApplicationRecord
  filterrific(
    default_filter_params: {sorted_by: 'relevance_asc'},
    available_filters: %i[with_start_date_gte
                          with_end_date_lte
                          with_language
                          with_mooc_provider_id
                          with_subtitle_languages
                          duration_filter_options
                          start_filter_options
                          with_tracks
                          search_query
                          sorted_by
                          bookmarked]
  )
  include PublicActivity::Common

  belongs_to :mooc_provider
  belongs_to :organisation
  has_one :previous_iteration, foreign_key: 'previous_iteration_id', class_name: 'Course'
  has_one :following_iteration, foreign_key: 'following_iteration_id', class_name: 'Course'
  has_many :recommendations, dependent: :destroy
  has_many :completions, dependent: :destroy
  has_and_belongs_to_many :users
  has_many :bookmarks, dependent: :destroy
  has_many :evaluations, dependent: :destroy
  has_many :tracks, class_name: 'CourseTrack', dependent: :destroy
  has_many :user_dates, dependent: :destroy

  has_attached_file :course_image,
    styles: {
      thumb: '100x100#',
      original: '300x300>'
    },
    convert_options: {all: '-quality 95'},
    s3_storage_class: 'REDUCED_REDUNDANCY',
    s3_permissions: 'public-read',
    default_url: Settings.root_url + '/data/course_picture_default.png'

  validates_attachment_content_type :course_image, content_type: /\Aimage\/.*\Z/

  validates :tracks, length: {minimum: 1}

  before_save :check_and_update_duration
  after_save :create_and_update_course_connections
  before_destroy :delete_dangling_course_connections
  before_destroy :handle_activities, prepend: true

  scope :sorted_by, ->(sort_option) do
    direction = sort_option.match?(/desc$/) ? 'desc' : 'asc'
    case sort_option.to_s
      when /^name_/
        order("LOWER(courses.name) #{direction}")
      when /^start_date_/
        order("courses.start_date #{direction} NULLS LAST")
      when /^duration_/
        order("courses.calculated_duration_in_days IS NULL, courses.calculated_duration_in_days #{direction}")
      when /^relevance_/
        order("CASE
                WHEN start_date > to_timestamp('#{(Time.zone.now - 1.week).strftime('%Y-%m-%d')}', 'YYYY-MM-DD') THEN 1
                WHEN start_date <= to_timestamp('#{(Time.zone.now - 1.week).strftime('%Y-%m-%d')}', 'YYYY-MM-DD') AND end_date IS NOT NULL AND end_date > to_timestamp('#{Time.zone.now.strftime('%Y-%m-%d')}', 'YYYY-MM-DD') THEN 2
                WHEN start_date <= to_timestamp('#{(Time.zone.now - 1.week).strftime('%Y-%m-%d')}', 'YYYY-MM-DD') AND end_date IS NOT NULL AND end_date <= to_timestamp('#{Time.zone.now.strftime('%Y-%m-%d')}', 'YYYY-MM-DD') THEN 3
                WHEN start_date IS NULL THEN 5
                ELSE 4
              END,
              start_date ASC")
      else
        raise ArgumentError.new "Invalid sort option: #{sort_option.inspect}"
    end
  end

  scope :search_query, ->(query) do
    if query.blank?
      nil
    else
      terms = query.mb_chars.downcase.to_s.split(/\s+/)

      # rubocop:disable Style/BlockDelimiters
      terms = terms.map {|e|
        e.prepend('%')
        (e.tr('*', '%') + '%').gsub(/%+/, '%')
      }
      # rubocop:enable Style/BlockDelimiters

      num_or_conds = 2
      where(
        terms.map do |_term|
          "(LOWER(courses.name) LIKE ?) OR (LOWER(COALESCE(courses.course_instructors, '')) LIKE ?)"
        end.join(' AND '),
        *terms.map {|e| [e] * num_or_conds }.flatten
      )
    end
  end

  scope :with_start_date_gte, ->(reference_time) do
    parsed_date = Time.zone.parse(reference_time.to_s)
    if parsed_date.blank?
      nil
    else
      where('courses.start_date IS NOT NULL AND (courses.start_date >= ?) ',
        parsed_date.strftime('%Y-%m-%d %H:%M:%S.%6N'))
    end
  end

  scope :with_end_date_lte, ->(reference_time) do
    parsed_date = Time.zone.parse(reference_time.to_s)
    if parsed_date.blank?
      nil
    else
      where('courses.end_date IS NOT NULL AND (courses.end_date <= ?) ',
        parsed_date.strftime('%Y-%m-%d %H:%M:%S.%6N'))
    end
  end

  scope :with_language, ->(reference_language) do
    where('courses.language IS NOT NULL AND (courses.language LIKE ? OR courses.language LIKE ?)',
      "#{reference_language}%", "%,#{reference_language}%")
  end

  scope :with_mooc_provider_id, ->(reference_mooc_provider_id) do
    where(mooc_provider_id: [*reference_mooc_provider_id])
  end

  scope :with_subtitle_languages, ->(reference_subtitle_languages) do
    where('courses.subtitle_languages LIKE ? OR courses.subtitle_languages LIKE ?',
      "#{reference_subtitle_languages}%", "%,#{reference_subtitle_languages}%")
  end

  scope :with_tracks, ->(reference_track_options) do
    if reference_track_options[:costs].present? && reference_track_options[:certificate].blank?
      case reference_track_options[:costs]
        when 'free'
          where(id: where('course_tracks.costs IS NOT NULL AND course_tracks.costs = 0').joins(:tracks).collect(&:id).uniq)
        when 'range1'
          where(id: where('course_tracks.costs IS NOT NULL AND course_tracks.costs <= 30.0 AND course_tracks.costs > 0.0').joins(:tracks).collect(&:id).uniq)
        when 'range2'
          where(id: where('course_tracks.costs IS NOT NULL AND course_tracks.costs <= 60.0 AND course_tracks.costs > 30.0').joins(:tracks).collect(&:id).uniq)
        when 'range3'
          where(id: where('course_tracks.costs IS NOT NULL AND course_tracks.costs <= 90.0 AND course_tracks.costs > 60.0').joins(:tracks).collect(&:id).uniq)
        when 'range4'
          where(id: where('course_tracks.costs IS NOT NULL AND course_tracks.costs <= 150.0 AND course_tracks.costs > 90.0').joins(:tracks).collect(&:id).uniq)
        when 'range5'
          where(id: where('course_tracks.costs IS NOT NULL AND course_tracks.costs <= 200.0 AND course_tracks.costs > 150.0').joins(:tracks).collect(&:id).uniq)
        when 'range6'
          where(id: where('course_tracks.costs IS NOT NULL AND course_tracks.costs > 200.0').joins(:tracks).collect(&:id).uniq)
      end
    elsif reference_track_options[:costs].blank? && reference_track_options[:certificate].present?
      where('course_tracks.course_track_type_id = ?', reference_track_options[:certificate]).joins(:tracks)
    elsif reference_track_options[:costs].present? && reference_track_options[:certificate].present?
      case reference_track_options[:costs]
        when 'free'
          where(id: where('course_tracks.costs IS NOT NULL AND course_tracks.costs = 0 AND course_tracks.course_track_type_id = ?', reference_track_options[:certificate]).joins(:tracks).collect(&:id).uniq)
        when 'range1'
          where(id: where('course_tracks.costs IS NOT NULL AND course_tracks.costs <= 30.0 AND course_tracks.costs > 0.0 AND course_tracks.course_track_type_id = ?', reference_track_options[:certificate]).joins(:tracks).collect(&:id).uniq)
        when 'range2'
          where(id: where('course_tracks.costs IS NOT NULL AND course_tracks.costs <= 60.0 AND course_tracks.costs > 30.0 AND course_tracks.course_track_type_id = ?', reference_track_options[:certificate]).joins(:tracks).collect(&:id).uniq)
        when 'range3'
          where(id: where('course_tracks.costs IS NOT NULL AND course_tracks.costs <= 90.0 AND course_tracks.costs > 60.0 AND course_tracks.course_track_type_id = ?', reference_track_options[:certificate]).joins(:tracks).collect(&:id).uniq)
        when 'range4'
          where(id: where('course_tracks.costs IS NOT NULL AND course_tracks.costs <= 150.0 AND course_tracks.costs > 90.0 AND course_tracks.course_track_type_id = ?', reference_track_options[:certificate]).joins(:tracks).collect(&:id).uniq)
        when 'range5'
          where(id: where('course_tracks.costs IS NOT NULL AND course_tracks.costs <= 200.0 AND course_tracks.costs > 150.0 AND course_tracks.course_track_type_id = ?', reference_track_options[:certificate]).joins(:tracks).collect(&:id).uniq)
        when 'range6'
          where(id: where('course_tracks.costs IS NOT NULL AND course_tracks.costs > 200.0 AND course_tracks.course_track_type_id = ?', reference_track_options[:certificate]).joins(:tracks).collect(&:id).uniq)
      end
    end
  end

  scope :start_filter_options, ->(reference_start_options) do
    case reference_start_options.to_s
      when 'now'
        where('courses.start_date IS NOT NULL AND courses.start_date < ? AND (courses.calculated_duration_in_days IS NOT NULL AND ((DATE ? - courses.calculated_duration_in_days) <  courses.start_date))', Time.zone.now, Time.zone.today)
      when 'past'
        where('(courses.calculated_duration_in_days IS NOT NULL AND ((DATE ? - courses.calculated_duration_in_days) >  courses.start_date))  OR (courses.end_date IS NOT NULL AND ? > courses.end_date)', Time.zone.now, Time.zone.now)
      when 'soon'
        where('courses.start_date > ? AND courses.start_date <= ?', Time.zone.now, (Time.zone.now + 2.weeks))
      when 'future'
        where('courses.start_date > ?', (Time.zone.now + 2.weeks))
    end
  end

  SHORT_DURATION = 28 # 4 weeks
  SHORT_MEDIUM_DURATION = 42 # 6 weeks
  MEDIUM_DURATION = 56 # 8 weeks
  MEDIUM_LONG_DURATION = 84 # 12 weeks

  scope :duration_filter_options, ->(reference_duration_option) do
    case reference_duration_option.to_s
      when 'short'
        where('courses.calculated_duration_in_days <= ?', SHORT_DURATION)
      when 'short-medium'
        where('courses.calculated_duration_in_days > ? AND courses.calculated_duration_in_days <= ?', SHORT_DURATION, SHORT_MEDIUM_DURATION)
      when 'medium'
        where('courses.calculated_duration_in_days > ? AND courses.calculated_duration_in_days <= ?', SHORT_MEDIUM_DURATION, MEDIUM_DURATION)
      when 'medium-long'
        where('courses.calculated_duration_in_days > ? AND courses.calculated_duration_in_days <= ?', MEDIUM_DURATION, MEDIUM_LONG_DURATION)
      when 'long'
        where('courses.calculated_duration_in_days > ?', MEDIUM_LONG_DURATION)
    end
  end

  scope :bookmarked, ->(user_id) do
    if (user_id.is_a? Integer) && user_id.zero?
      nil
    else
      user = User.find(user_id)
      course_ids = []
      user.bookmarks.each {|bookmark| course_ids.push(bookmark.course.id) }
      where(id: course_ids)
    end
  end

  def self.options_for_costs
    [[I18n.t('courses.filter.costs.free'), 'free'],
     [I18n.t('courses.filter.costs.range1'), 'range1'],
     [I18n.t('courses.filter.costs.range2'), 'range2'],
     [I18n.t('courses.filter.costs.range3'), 'range3'],
     [I18n.t('courses.filter.costs.range4'), 'range4'],
     [I18n.t('courses.filter.costs.range5'), 'range5'],
     [I18n.t('courses.filter.costs.range6'), 'range6']]
  end

  def self.options_for_start
    [[I18n.t('courses.filter.start.now'), 'now'],
     [I18n.t('courses.filter.start.past'), 'past'],
     [I18n.t('courses.filter.start.soon'), 'soon'],
     [I18n.t('courses.filter.start.future'), 'future']]
  end

  def self.options_for_duration
    [[I18n.t('courses.filter.duration.short'), 'short'],
     [I18n.t('courses.filter.duration.short_medium'), 'short-medium'],
     [I18n.t('courses.filter.duration.medium'), 'medium'],
     [I18n.t('courses.filter.duration.medium_long'), 'medium-long'],
     [I18n.t('courses.filter.duration.long'), 'long']]
  end

  def self.options_for_languages
    [[I18n.t('language.en'), 'en'],
     [I18n.t('language.de'), 'de'],
     [I18n.t('language.es'), 'es'],
     [I18n.t('language.fr'), 'fr'],
     [I18n.t('language.zh'), 'zh'],
     [I18n.t('language.pt'), 'pt'],
     [I18n.t('language.ru'), 'ru'],
     [I18n.t('language.he'), 'he'],
     [I18n.t('language.it'), 'it'],
     [I18n.t('language.ar'), 'ar']]
  end

  def self.options_for_subtitle_languages
    [[I18n.t('language.en'), 'en'],
     [I18n.t('language.de'), 'de'],
     [I18n.t('language.es'), 'es'],
     [I18n.t('language.fr'), 'fr'],
     [I18n.t('language.zh'), 'zh'],
     [I18n.t('language.pt'), 'pt'],
     [I18n.t('language.ru'), 'ru'],
     [I18n.t('language.it'), 'it'],
     [I18n.t('language.ar'), 'ar'],
     [I18n.t('language.ro'), 'ro'],
     [I18n.t('language.el'), 'el'],
     [I18n.t('language.fil'), 'fil'],
     [I18n.t('language.uk'), 'uk'],
     [I18n.t('language.vi'), 'vi'],
     [I18n.t('language.tr'), 'tr'],
     [I18n.t('language.lt'), 'lt'],
     [I18n.t('language.kk'), 'kk'],
     [I18n.t('language.sr'), 'sr'],
     [I18n.t('language.ko'), 'ko'],
     [I18n.t('language.ja'), 'ja'],
     [I18n.t('language.nl'), 'nl'],
     [I18n.t('language.id'), 'id']]
  end

  def self.options_for_sorted_by
    [[I18n.t('courses.filter.sort.start_date_relevance'), 'relevance_asc'],
     [I18n.t('courses.filter.sort.name_asc'), 'name_asc'],
     # [I18n.t('courses.filter.sort.name_desc'), 'name_desc'],
     [I18n.t('courses.filter.sort.start_date_asc'), 'start_date_asc'],
     [I18n.t('courses.filter.sort.start_date_desc'), 'start_date_desc'],
     [I18n.t('courses.filter.sort.duration_asc'), 'duration_asc'],
     [I18n.t('courses.filter.sort.duration_desc'), 'duration_desc']]
  end

  self.per_page = 20

  def bookmarked_by_user?(user)
    bookmarks.where(user_id: user.id).any?
  end

  def self.get_course_by_mooc_provider_id_and_provider_course_id(mooc_provider_id, provider_course_id)
    course = Course.find_by(provider_course_id: provider_course_id, mooc_provider_id: mooc_provider_id)
    return course if course.present?
  end

  def self.update_course_rating_attributes(course_id)
    course = Course.find(course_id)
    course_evaluations = Evaluation.find_by(course_id: course_id)
    if course_evaluations.present?
      course.calculated_rating = Evaluation.where(course_id: course_id).average(:rating)
      course.rating_count = Evaluation.where(course_id: course_id).count
    else
      course.calculated_rating = 0
      course.rating_count = 0
    end
    course.save
  end

  def handle_activities
    PublicActivity::Activity.find_each do |activity|
      course = case activity.trackable_type
                 when 'Recommendation' then Recommendation.find(activity.trackable_id).course
                 when 'Course' then Course.find(activity.trackable_id)
                 when 'Bookmark' then Bookmark.find(activity.trackable_id).course
               end
      activity.destroy if course == self
    end
  end

  def self.process_uri(uri)
    return if uri.nil? || Settings.domain != 'mammooc.org'
    image_url = URI.parse(uri)
    image_url.scheme = 'https'
    image_url.to_s
  end

  private

  def check_and_update_duration
    return unless end_date && start_date
    if start_date_is_before_end_date
      if calculated_duration_in_days != (end_date.to_date - start_date.to_date).to_i
        self.calculated_duration_in_days = (end_date.to_date - start_date.to_date).to_i
        save
      end
    else
      self.end_date = nil
    end
  end

  def start_date_is_before_end_date
    start_date <= end_date ? (return true) : (return false)
  end

  def delete_dangling_course_connections
    check_and_delete_previous_course_connection
    check_and_delete_following_course_connection
  end

  def check_and_delete_previous_course_connection
    return unless previous_iteration_id
    previous_course = Course.find(previous_iteration_id)
    return unless previous_course.following_iteration_id == id
    previous_course.following_iteration_id = nil
    previous_course.save
  end

  def check_and_delete_following_course_connection
    return unless following_iteration_id
    following_course = Course.find(following_iteration_id)
    return unless following_course.previous_iteration_id == id
    following_course.previous_iteration_id = nil
    following_course.save
  end

  def create_and_update_course_connections
    check_and_update_previous_course_connection
    check_and_update_following_course_connection
  end

  def check_and_update_previous_course_connection
    return unless previous_iteration_id
    previous_course = Course.find(previous_iteration_id)
    return unless previous_course.following_iteration_id != id
    previous_course.following_iteration_id = id
    previous_course.save
  end

  def check_and_update_following_course_connection
    return unless following_iteration_id
    following_course = Course.find(following_iteration_id)
    return unless following_course.previous_iteration_id != id
    following_course.previous_iteration_id = id
    following_course.save
  end
end

# rubocop:enable Style/Lambda
