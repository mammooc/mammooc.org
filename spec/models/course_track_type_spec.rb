# encoding: utf-8
# frozen_string_literal: true
require 'rails_helper'

RSpec.describe CourseTrackType, type: :model do
  describe 'options for select course track type' do
    let!(:track_type1) { FactoryGirl.create(:course_track_type) }
    let!(:track_type2) { FactoryGirl.create(:course_track_type) }
    let!(:track_type3) { FactoryGirl.create(:course_track_type) }

    it 'returns array of name and id' do
      options = described_class.options_for_select
      expect(options).to match_array([[track_type1.title, track_type1.id], [track_type2.title, track_type2.id], [track_type3.title, track_type3.id]])
    end
  end
end
