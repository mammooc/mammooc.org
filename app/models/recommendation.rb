# -*- encoding : utf-8 -*-
class Recommendation < ActiveRecord::Base
  belongs_to :author, class_name: 'User'
  belongs_to :course
  belongs_to :group
  has_many :comments
  has_and_belongs_to_many :users

  def self.sorted_recommendations_for_course_and_user(course, user)
    course_recommendations = []
    recommendations_of_user = user.recommendations

    user.groups.each do |group|
      recommendations_of_user += group.recommendations
    end

    recommendations_of_user.each do |recommendation|
      if recommendation.course == course
        course_recommendations.push(recommendation)
      end
    end

    course_recommendations.uniq.sort_by(&:created_at).reverse!
  end
end
