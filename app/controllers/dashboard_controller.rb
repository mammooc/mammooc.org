class DashboardController < ApplicationController

  NUMBER_OF_SHOWN_RECOMMENDATIONS = 2

  def dashboard
    all_my_sorted_recommendations = Recommendation.sorted_recommendations_for(current_user, current_user.groups)
    @recommendations = all_my_sorted_recommendations.first(NUMBER_OF_SHOWN_RECOMMENDATIONS)
    @number_of_recommendations = all_my_sorted_recommendations.length

  end
end
