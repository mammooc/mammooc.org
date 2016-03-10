# encoding: utf-8
# frozen_string_literal: true

class EnableUuidOsspExtension < ActiveRecord::Migration
  def change
    enable_extension 'uuid-ossp'
  end
end
