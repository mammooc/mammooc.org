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

    @activities = PublicActivity::Activity.order("created_at desc").where(owner_id: @current_user.connected_users_ids)
    @activity_courses = Hash.new
    if @activities
      @activities.each do |activity|
        if activity.recipient_id
          if activity.recipient_id != @current_user.id && !@current_user.connected_groups_ids.include?(activity.recipient_id)
            @activities -= [activity]
          end
        end
        if activity.trackable_type == 'Recommendation'
          @activity_courses[activity.id] = Recommendation.find(activity.trackable_id).course
        elsif activity.trackable_type == 'Course'
          @activity_courses[activity.id] = Course.find(activity.trackable_id)#
        elsif activity.trackable_type == 'Bookmark'
          @activity_courses[activity.id] = Bookmark.find(activity.trackable_id).course
        end
      end
    end
    @number_of_mandatory_recommendations = 0
    @recommendations.each do |recommendation|
      if recommendation.is_obligatory
        @number_of_mandatory_recommendations += 1
      end
    end
    respond_to do |format|
      format.html {}
      format.json { render :dashboard, status: :ok }
    end
  end
end
