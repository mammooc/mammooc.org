# -*- encoding : utf-8 -*-
class Group < ActiveRecord::Base
  has_many :user_groups
  has_many :users, through: :user_groups
  has_many :statistics
  has_many :recommendations
  has_many :course_requests
  has_many :group_invitations

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

  def self.group_images_hash_for_groups(groups, images = {},  style = :medium, expire_time = 3600)
    groups.each do |group|
      unless images.key?(group.id)
        images[group.id] = group.image.expiring_url(expire_time, style)
      end
    end
    images
  end

  def destroy
    UserGroup.destroy_all(group_id: id)
    GroupInvitation.where(group_id: id).update_all(group_id: nil)
    super
  end
end
