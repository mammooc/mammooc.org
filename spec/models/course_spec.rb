require 'rails_helper'

RSpec.describe Course, :type => :model do
  let(:provider) {FactoryGirl.create(:mooc_provider)}
  let(:course) {FactoryGirl.create(:course,
                                   mooc_provider_id: provider.id,
                                   start_date: DateTime.new(2015,03,15),
                                   end_date: DateTime.new(2015,03,17))}

  it "should set duration after creation" do
    expect(course.duration).to eq(2)
  end

  it "should update duration after update of start/end_time" do
    course.end_date = DateTime.new(2015,04,16)
    course.save
    expect(course.duration).to eq(32)
  end
end
