class Recommendation < ActiveRecord::Base
  belongs_to :user
  belongs_to :course
  has_many :comments
  has_and_belongs_to_many :groups
  has_and_belongs_to_many :users

  def self.sorted_recommendations_for(user, groups)
    all_recommendations = Hash.new

    if groups
      groups.each do |group|
        group.recommendations.each do |recommendation|
          all_recommendations[recommendation] = group
        end
      end
    end
    if user
      user.recommendations.each do |recommendation|
        all_recommendations[recommendation] = nil
      end
    end

    sorted_recommendations = all_recommendations.sort_by { |k, _| k.created_at}.reverse!
    return sorted_recommendations
  end
end
