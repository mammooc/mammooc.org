class Recommendation < ActiveRecord::Base
  belongs_to :author, class_name: "User"
  belongs_to :course
  belongs_to :group
  has_many :comments
  has_and_belongs_to_many :users

  def self.sorted_recommendations_for(user, groups, course)
    all_recommendations = Hash.new

    if groups
      groups.each do |group|
        group.recommendations.each do |recommendation|
          if course
            if recommendation.course == course
              all_recommendations[recommendation] = group
            end
          else
            all_recommendations[recommendation] = group
          end
        end
      end
    end
    if user
      user.recommendations.each do |recommendation|
        if course
          if recommendation.course == course
            all_recommendations[recommendation] = nil
          end
        else
          all_recommendations[recommendation] = nil
        end
      end
    end

    sorted_recommendations = all_recommendations.sort_by { |recommendation, _| recommendation.created_at}.reverse!
    return sorted_recommendations
  end
end
