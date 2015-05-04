# -*- encoding : utf-8 -*-
class HomeController < ApplicationController
  skip_before_action :require_login
end
