# -*- encoding : utf-8 -*-
class DashboardController < ApplicationController
  NUMBER_OF_SHOWN_RECOMMENDATIONS = 2

  def dashboard
    all_my_sorted_recommendations = current_user.recommendations.sort_by(&:created_at).reverse!
    @recommendations = all_my_sorted_recommendations.first(NUMBER_OF_SHOWN_RECOMMENDATIONS)
    @number_of_recommendations = all_my_sorted_recommendations.length
    @provider_logos = AmazonS3.instance.provider_logos_hash_for_recommendations(@recommendations)
    @profile_pictures = AmazonS3.instance.author_profile_images_hash_for_recommendations(@recommendations)
    @rating_picture = AmazonS3.instance.get_url('five_stars.png')

    respond_to do |format|
      format.html {}
      format.json { render :dashboard, status: :ok }
    end
  end
end
