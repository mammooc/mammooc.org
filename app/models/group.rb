# -*- encoding : utf-8 -*-
class Group < ActiveRecord::Base
  has_many :user_groups
  has_many :users, through: :user_groups
  has_many :statistics
  has_many :recommendations
  has_many :course_requests
  has_many :group_invitations
  include PublicActivity::Common

  has_attached_file :image,
    styles: {
      thumb: '100x100#',
      square: '300x300#',
      medium: '300x300>'},
    s3_storage_class: :reduced_redundancy,
    s3_permissions: :private,
    default_url: '/data/group_picture_default.png'

  # Validate the attached image is image/jpg, image/png, etc
  validates_attachment_content_type :image, content_type: /\Aimage\/.*\Z/
  validates_attachment_size :image, less_than: 1.megabyte

  before_destroy :handle_activities
  before_destroy :handle_recommendations

  def handle_activities
    PublicActivity::Activity.select {|activity| (activity.group_ids.present?) && (activity.group_ids.include? id) }.each do |activity|
      delete_group_from_activity activity
    end
  end

  def handle_recommendations
    recommendations.destroy
  end

  def delete_group_from_activity(activity)
    activity.group_ids -= [id]
    activity.save
    if activity.trackable_type == 'Recommendation'
      Recommendation.find(activity.trackable_id).delete_group_recommendation
    end
    return unless (activity.user_ids.blank?) && (activity.group_ids.blank?)
    activity.destroy
  end

  def self.group_images_hash_for_groups(groups, images = {},  style = :medium, expire_time = 3600)
    groups.each do |group|
      unless images.key?(group.id)
        images[group.id] = group.image.expiring_url(expire_time, style)
      end
    end
    images
  end

  def user_ids
    users.collect(&:id)
  end

  def destroy
    UserGroup.destroy_all(group_id: id)
    GroupInvitation.where(group_id: id).update_all(group_id: nil)
    super
  end

  def admins
    User.find(UserGroup.where(group_id: id, is_admin: true).collect(&:user_id))
  end

  def average_enrollments
    total_enrollments = 0
    total_members = 0
    users.each do |user|
      if user.course_enrollments_visible_for_group(self)
        total_enrollments += user.courses.length
        total_members += 1
      end
    end
    (total_enrollments.to_f / total_members.to_f).round(2)
  end

  def enrolled_courses_with_amount
    enrolled_courses_array = []
    users.each do |user|
      if user.course_enrollments_visible_for_group(self)
        enrolled_courses_array += user.courses
      end
    end
    enrolled_courses = []
    enrolled_courses_array.uniq.each do |enrolled_course|
      enrolled_courses.push(course: enrolled_course, count: enrolled_courses_array.count(enrolled_course))
    end
    enrolled_courses = enrolled_courses.sort_by {|course_hash| course_hash[:name] }.reverse
    enrolled_courses.sort_by {|course_hash| course_hash[:count] }.reverse
  end

  def enrolled_courses
    enrolled_courses_array = []
    users.each do |user|
      if user.course_enrollments_visible_for_group(self)
        enrolled_courses_array += user.courses
      end
    end
    enrolled_courses_array.uniq
  end

  def number_of_users_who_share_course_enrollments
    number = 0
    users.each do |user|
      number += 1 if user.course_enrollments_visible_for_group(self)
    end
    number
  end
end
