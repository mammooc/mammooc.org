# -*- encoding : utf-8 -*-
class MoocProvidersController < ApplicationController

  # GET /mooc_providers.json
  def index
    @mooc_providers = MoocProvider.all
  end
end
