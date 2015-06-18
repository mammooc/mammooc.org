# -*- encoding : utf-8 -*-
class CompletionsController < ApplicationController
  # GET /completions
  # GET /completions.json
  def index
    @user = User.find(completions_params[:user_id])
    @completions = Completion.where(user: @user)
  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def completions_params
    params.permit(:user_id)
  end
end
