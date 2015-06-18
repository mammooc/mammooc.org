# -*- encoding : utf-8 -*-
class CompletionsController < ApplicationController
  # GET /completions
  # GET /completions.json
  def index
    @completions = Completion.where(user: completions_params[:user_id])
  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def completions_params
    params.permit(:user_id)
  end
end
