# encoding: utf-8
# frozen_string_literal: true

class StaticPagesController < ApplicationController
  skip_before_action :require_login
end
