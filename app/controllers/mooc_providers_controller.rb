# encoding: utf-8
# frozen_string_literal: true

class MoocProvidersController < ApplicationController
  # GET /mooc_providers.json
  def index
    @mooc_providers = MoocProvider.all
  end
end
