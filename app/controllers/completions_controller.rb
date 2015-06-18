# -*- encoding : utf-8 -*-
class CompletionsController < ApplicationController
  # GET /completions
  # GET /completions.json
  def index
    @user = User.find(completions_params[:user_id])
    @completions = Completion.where(user: @user).sort_by(&:created_at).reverse
    courses = []
    @completions.each do |completion|
      courses.push(completion.course)
    end
    @provider_logos = AmazonS3.instance.provider_logos_hash_for_courses(courses)
  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def completions_params
    params.permit(:user_id)
  end
end
