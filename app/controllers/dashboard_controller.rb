class DashboardController < ApplicationController

  NUMBER_OF_SHOWN_RECOMMENDATIONS = 2

  def dashboard
    my_sorted_recommendations = current_user.recommendations.sort_by { | recommendation | recommendation.created_at }.reverse!
    @recommendations = my_sorted_recommendations.first(NUMBER_OF_SHOWN_RECOMMENDATIONS)
    @number_of_recommendations = current_user.recommendations.length
  end
end
