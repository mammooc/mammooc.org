# frozen_string_literal: true

class DashboardController < ApplicationController
  NUMBER_OF_SHOWN_RECOMMENDATIONS = 2

  def dashboard
    # Recommendations
    all_my_sorted_recommendations = Recommendation.filter_users(current_user.recommendations, [current_user]).sort_by(&:created_at).reverse!
    @recommendations = all_my_sorted_recommendations.first(NUMBER_OF_SHOWN_RECOMMENDATIONS)
    @number_of_recommendations = all_my_sorted_recommendations.length

    # Bookmarks
    @bookmarks = current_user.bookmarks

    # Activities
    @activities = PublicActivity::Activity.order('created_at desc').select {|activity| (current_user.connected_users_ids.include? activity.owner_id) && activity.user_ids.present? && (activity.user_ids.include? current_user.id) }
    @activity_courses = {}
    @activity_courses_bookmarked = {}
    if @activities
      @activities.each do |activity|
        @activity_courses[activity.id] = case activity.trackable_type
                                           when 'Recommendation' then Recommendation.find(activity.trackable_id).course
                                           when 'Course' then Course.find(activity.trackable_id)
                                           when 'Bookmark' then Bookmark.find(activity.trackable_id).course
                                         end
        @activity_courses_bookmarked[activity.id] = @activity_courses[activity.id].bookmarked_by_user? current_user if @activity_courses[activity.id].present?
        # privacy settings
        if activity.key == 'course.enroll'
          @activities -= [activity] unless activity.owner.course_enrollments_visible_for_user(current_user)
        end
      end
      @number_of_activities = @activities.length
    end

    @number_of_mandatory_recommendations = 0
    all_my_sorted_recommendations.each do |recommendation|
      if recommendation.is_obligatory
        @number_of_mandatory_recommendations += 1
        @number_of_recommendations -= 1
      end
    end

    @profile_pictures = User.author_profile_images_hash_for_activities(@activities)
    @user_picture = @current_user.profile_image.expiring_url(3600, :square)
    @provider_logos = AmazonS3.instance.provider_logos_hash_for_recommendations(@recommendations)

    @current_dates_to_show = current_user.dates.where('date >= ?', Time.zone.today).sort_by(&:date).first(3)

    respond_to do |format|
      format.html {}
      format.json { render :dashboard, status: :ok }
    end
  end
end
