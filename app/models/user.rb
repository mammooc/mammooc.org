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
  has_many :recommendations
  has_and_belongs_to_many :recommendations
  has_many :comments
  has_many :mooc_provider_users, dependent: :destroy
  has_many :mooc_providers, through: :mooc_provider_users
  has_many :completions
  has_and_belongs_to_many :courses
  has_many :course_requests
  has_many :approvals
  has_many :progresses
  has_many :bookmarks
  has_many :evaluations
  has_many :user_assignments
  has_many :user_identities, dependent: :destroy

  has_attached_file :profile_image,
                    styles: {
                        thumb: '100x100#',
                        square: '200x200#',
                        medium: '300x300#'},
                    s3_storage_class: :reduced_redundancy,
                    s3_permissions: :private,
                    default_url: '/assets/profile_picture_default.png'

  # Validate the attached image is image/jpg, image/png, etc
  validates_attachment_content_type :profile_image, :content_type => /\Aimage\/.*\Z/

  before_destroy :handle_group_memberships, prepend: true
  after_commit :save_primary_email, on: :create

  def self.author_profile_images_hash_for_recommendations recommendations, style = :medium, expire_time = 3600
    author_images = {}
    recommendations.each do |recommendation|
      unless author_images.key?("#{recommendation.author.id} #{recommendation.author.profile_image_file_name}")
        author_images["#{recommendation.author.id} #{recommendation.author.profile_image_file_name}"] = recommendation.author.profile_image.expiring_url(expire_time, style)
      end
    end
    author_images
  end

  def self.user_profile_images_hash_for_users users, images = {}, style = :medium, expire_time = 3600
    users.each do |user|
      unless images.key?("#{user.id} #{user.profile_image_file_name}")
        images["#{user.id} #{user.profile_image_file_name}"] = user.profile_image.expiring_url(expire_time, style)
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

  def common_groups_with_user(other_user)
    (other_user.groups.to_a.collect {|group| groups.include?(group) ? group : nil }).compact
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
    return if @primary_email_object.user.blank?
    @primary_email_object.save!
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

    # Create the user if needed
    if user.nil?

      # Get the existing user by email if the provider gives us a verified email.
      # If no verified email was provided we assign a temporary email and ask the
      # user to verify it on the next step via UsersController.finish_signup

      # NOTE: email verification is still disabled
      # email_is_verified = auth.info.email && (auth.info.verified || auth.info.verified_email)
      email = auth.info.email # if email_is_verified
      user = User.find_by(email: email) if email

      # Create the user if it's a new registration
      if user.nil?
        user = User.new(
          first_name: auth.info.first_name,
          last_name: auth.info.last_name,
          # ToDo: upload image without form
          #profile_image_id: auth.info.image || 'profile_picture_default.png',
          email: email ? email : "change@me-#{auth.uid}-#{auth.provider}.com",
          password: Devise.friendly_token[0, 20],
          password_autogenerated: true
        )
        # user.skip_confirmation!
        user.save!
      end
    end

    # Associate the identity with the user if needed
    if identity.user != user
      identity.user = user
      identity.save!
    end
    user
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
