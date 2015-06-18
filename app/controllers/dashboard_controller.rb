# -*- encoding : utf-8 -*-
class DashboardController < ApplicationController
  NUMBER_OF_SHOWN_RECOMMENDATIONS = 2

  def dashboard
    # Recommendations
    all_my_sorted_recommendations = Recommendation.filter_users(current_user.recommendations, [current_user]).sort_by(&:created_at).reverse!
    @recommendations = all_my_sorted_recommendations.first(NUMBER_OF_SHOWN_RECOMMENDATIONS)
    @number_of_recommendations = all_my_sorted_recommendations.length
    @provider_logos = AmazonS3.instance.provider_logos_hash_for_recommendations(@recommendations)
    @profile_pictures = User.author_profile_images_hash_for_recommendations(@recommendations)
    @rating_picture = AmazonS3.instance.get_url('five_stars.png')
    @user_picture = @current_user.profile_image.expiring_url(3600, :square)
    # Bookmarks
    @bookmarks = current_user.bookmarks

    @activities = PublicActivity::Activity.order('created_at desc').where(owner_id: @current_user.connected_users_ids)
    @activity_courses = {}
    @activity_courses_bookmarked = {}
    if @activities
      @activities.each do |activity|
        if activity.user_ids.present? && (activity.user_ids.include? current_user.id)
          @activity_courses[activity.id] = case activity.trackable_type
                                             when 'Recommendation' then Recommendation.find(activity.trackable_id).course
                                             when 'Course' then Course.find(activity.trackable_id)
                                             when 'Bookmark' then Bookmark.find(activity.trackable_id).course
                                           end
          @activity_courses_bookmarked[activity.id] = @activity_courses[activity.id].bookmarked_by_user? current_user
        else
          @activities -= [activity]
        end
      end
      @number_of_activities = @activities.length
    end
    @number_of_mandatory_recommendations = 0
    @recommendations.each do |recommendation|
      @number_of_mandatory_recommendations += 1 if recommendation.is_obligatory
    end
    respond_to do |format|
      format.html {}
      format.json { render :dashboard, status: :ok }
    end
  end
end
