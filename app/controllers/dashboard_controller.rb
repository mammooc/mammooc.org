class DashboardController < ApplicationController

  NUMBER_OF_SHOWN_RECOMMENDATIONS = 2

  def dashboard
    all_my_recommendations = Hash.new
    current_user.groups.each do |group|
      group.recommendations.each do |recommendation|
        all_my_recommendations[recommendation] = group
      end
    end
    current_user.recommendations.each do |recommendation|
      all_my_recommendations[recommendation] = nil
    end

    my_sorted_recommendations = all_my_recommendations.sort_by { |k, _| k.created_at}.reverse!
    @recommendations = my_sorted_recommendations.first(NUMBER_OF_SHOWN_RECOMMENDATIONS)
    @number_of_recommendations = all_my_recommendations.length
  end
end
