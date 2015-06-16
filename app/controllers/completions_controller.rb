# -*- encoding : utf-8 -*-
class CompletionsController < ApplicationController
  # GET /completions
  # GET /completions.json
  def index
    @completions = Completion.where(user: current_user)
  end
end
