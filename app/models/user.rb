# -*- encoding : utf-8 -*-
class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :omniauthable and :encryptable
  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :trackable, :validatable, :omniauthable
  validates :first_name, :last_name, presence: true
  has_many :emails, class_name: 'UserEmail', dependent: :destroy
  has_many :user_groups, dependent: :destroy
  has_many :groups, through: :user_groups
  has_many :created_recommendations, foreign_key: 'author_id', class_name: 'Recommendation'
  has_and_belongs_to_many :recommendations
  has_many :comments
  has_many :mooc_provider_users, dependent: :destroy
  has_many :mooc_providers, through: :mooc_provider_users
  has_many :completions, dependent: :destroy
  has_and_belongs_to_many :courses
  has_many :course_requests
  has_many :approvals
  has_many :progresses
  has_many :bookmarks, dependent: :destroy
  has_many :evaluations
  has_many :user_assignments
  has_many :identities, class_name: 'UserIdentity', dependent: :destroy
  has_many :settings, class_name: 'UserSetting', dependent: :destroy

  has_attached_file :profile_image,
    styles: {
      thumb: '100x100#',
      square: '300x300#',
      medium: '300x300>',
      original: '300x300>'},
    s3_storage_class: :reduced_redundancy,
    s3_permissions: :private,
    default_url: '/data/profile_picture_default.png'

  # Validate the attached image is image/jpg, image/png, etc
  validates_attachment_content_type :profile_image, content_type: /\Aimage\/.*\Z/
  validates_attachment_size :profile_image, less_than: 1.megabyte

  before_destroy :handle_group_memberships, prepend: true
  before_destroy :handle_evaluations, prepend: true
  before_destroy :handle_activities
  before_destroy :handle_recommendations
  after_commit :save_primary_email, on: [:create, :update]

  def self.author_profile_images_hash_for_recommendations(recommendations, style = :square, expire_time = 3600)
    author_images = {}
    recommendations.each do |recommendation|
      unless author_images.key?("#{recommendation.author.id}")
        author_images["#{recommendation.author.id}"] = recommendation.author.profile_image.expiring_url(expire_time, style)
      end
    end
    author_images
  end

  def self.author_profile_images_hash_for_activities(activities, style = :square, expire_time = 3600)
    author_images = {}
    activities.each do |activity|
      unless author_images.key?("#{activity.owner_id}")
        author_images["#{activity.owner_id}"] = activity.owner.profile_image.expiring_url(expire_time, style)
      end
    end
    author_images
  end

  def self.user_profile_images_hash_for_users(users, images = {}, style = :square, expire_time = 3600)
    users.each do |user|
      unless images.key?("#{user.id}")
        images["#{user.id}"] = user.profile_image.expiring_url(expire_time, style)
      end
    end
    images
  end

  def handle_group_memberships
    groups.each do |group|
      if group.users.count > 1
        if UserGroup.find_by(group: group, user: self).is_admin
          if UserGroup.where(group: group, is_admin: true).count == 1
            return false
          end
        end
      else
        group.destroy
      end
    end
  end

  def handle_evaluations
    evaluations.each do |evaluation|
      evaluation.user_id = nil
      evaluation.rated_anonymously = true
      evaluation.save
    end
  end

  def handle_recommendations
    recommendations.each do |recommendation|
      recommendation.delete_user_from_recommendation self
    end
    Recommendation.where(author: self).destroy_all
  end

  def handle_activities
    PublicActivity::Activity.where(owner_id: id).find_each(&:destroy)
    PublicActivity::Activity.select {|activity| (activity.user_ids.present?) && (activity.user_ids.include? id) }.each do |activity|
      delete_user_from_activity activity
    end
  end

  def delete_user_from_activity(activity)
    activity.user_ids -= [id]
    activity.save
    if activity.trackable_type == 'Recommendation'
      Recommendation.find(activity.trackable_id).delete_user_from_recommendation self
    end
    return unless (activity.user_ids.blank?) && (activity.group_ids.blank?)
    activity.destroy
  end

  def common_groups_with_user(other_user)
    (other_user.groups.to_a.collect {|group| groups.include?(group) ? group : nil }).compact
  end

  def groups_sorted_by_admin_state_and_name(groups_to_sort = groups)
    groups_to_sort.sort_by do |group|
      [group.admins.include?(self) ? 0 : 1, group.name]
    end
  end

  # Disable email for devise - we will check with validations within the UserEmail model
  def email_required?
    false
  end

  def email_changed?
    false
  end

  # Access the primary_email more easily. This is required for devise
  def primary_email
    primary_email_object = emails.find_by(is_primary: true)
    return unless primary_email_object.present?
    primary_email_object.address
  end

  def primary_email=(primary_email_address)
    @primary_email_object = emails.find_by(is_primary: true)
    if @primary_email_object.present?
      @primary_email_object.address = primary_email_address
    else
      @primary_email_object = UserEmail.new
      @primary_email_object.address = primary_email_address.strip.downcase
      @primary_email_object.is_primary = true
      @primary_email_object.is_verified = false
    end
  end

  def self.find_by_primary_email(email_address)
    primary_email_object = UserEmail.find_by(address: email_address.strip.downcase, is_primary: true)
    return unless primary_email_object.present?
    primary_email_object.user
  end

  def self.find_first_by_auth_conditions(warden_conditions)
    conditions = warden_conditions.dup
    email_address = conditions.delete(:primary_email)
    if email_address.present?
      User.find_by_primary_email(email_address)
    else
      super(warden_conditions)
    end
  end

  def self.find_for_omniauth(auth, signed_in_resource = nil)
    # Get the identity and user if they exist
    identity = UserIdentity.find_for_omniauth(auth)

    # If a signed_in_resource is provided it always overrides the existing user
    # to prevent the identity being locked with accidentally created accounts.
    # Note that this may leave zombie accounts (with no associated identity) which
    # can be cleaned up at a later date.
    user = signed_in_resource ? signed_in_resource : identity.user

    email = auth.info.email

    # Create the user if needed
    if user.nil?
      user = User.find_by_primary_email(email.downcase) if email

      # We can't find a user with this email, so let's create
      if user.nil?
        first_name = auth.extra.raw_info.present? && auth.extra.raw_info.middle_name ? "#{auth.info.first_name} #{auth.extra.raw_info.middle_name}" : auth.info.first_name
        last_name = auth.info.last_name
        autogenerated = "autogenerated@#{auth.uid}-#{auth.provider}.com"
        user = User.new(
          first_name: first_name.present? ? first_name : autogenerated,
          last_name: last_name.present? ? last_name : autogenerated,
          profile_image: process_uri(auth.info.image),
          primary_email: email.present? ? email.downcase : autogenerated,
          password: Devise.friendly_token[0, 20],
          password_autogenerated: true
        )
        user.save!
      end
    else
      # existing user - do we have the email address?
      if email.present? && !user.emails.pluck(:address).include?(email.downcase)
        begin
          UserEmail.create!(user: user, address: email.downcase, is_primary: false)
          user.profile_image = process_uri(auth.info.image)
          user.save!

        rescue ActiveRecord::RecordInvalid
          # TODO: Merge accounts!
          Rails.logger.error "This email address is associated to another user. The found identity will be changed later so that the existing account won't be accessible any longer."
        end
      end
    end

    email_is_verified = email && (auth.info.verified || auth.info.verified_email)
    if email_is_verified
      primary_email_object = UserEmail.find_by_address(email.downcase)
      primary_email_object.is_verified = true
      primary_email_object.save!
    end

    # Associate the identity with the user if needed
    if identity.user != user
      identity.user = user
      identity.save!
    end
    user
  end

  def connected_users_ids
    connected_users = []
    groups.each do |group|
      connected_users += group.users.reject {|user| user.id == id }.collect(&:id)
    end
    connected_users.uniq
  end

  def connected_users
    connected_users = []
    groups.each do |group|
      connected_users += group.users.reject {|user| user.id == id }
    end
    connected_users.uniq
  end

  def connected_groups_ids
    groups.collect(&:id)
  end

  def self.process_uri(uri)
    return if uri.nil?
    avatar_url = URI.parse(uri)
    avatar_url.scheme = 'https'
    avatar_url.to_s
  end

  def first_name_autogenerated?
    autogenerated = false
    UserIdentity.where(user: self).find_each do |identity|
      autogenerated = true if ("autogenerated@#{identity.provider_user_id}-#{identity.omniauth_provider}.com".downcase.match(first_name.downcase)).present?
    end
    autogenerated
  end

  def last_name_autogenerated?
    autogenerated = false
    UserIdentity.where(user: self).find_each do |identity|
      autogenerated = true if ("autogenerated@#{identity.provider_user_id}-#{identity.omniauth_provider}.com".downcase.match(last_name.downcase)).present?
    end
    autogenerated
  end

  def setting(key, create_new = false)
    setting = settings.find_by(name: key)
    if setting.nil? && create_new
      setting = UserSetting.create!(name: key, user: self)
    end
    setting
  end

  private

  def save_primary_email
    return unless @primary_email_object.present?
    if @primary_email_object.user.blank?
      @primary_email_object.user = self
    elsif @primary_email_object.user != self
      raise ActiveRecord::RecordNotSaved('The provided user does not belongs to the email address')
    end
    @primary_email_object.save!
  end
end
