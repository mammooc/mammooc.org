require 'rails_helper'

RSpec.describe Course, :type => :model do
  let!(:provider) { FactoryGirl.create(:mooc_provider) }
  let!(:course1) { FactoryGirl.create(:course,
                                      mooc_provider_id: provider.id,
                                      start_date: DateTime.new(2015,03,15),
                                      end_date: DateTime.new(2015,03,17)) }
  let!(:course2) { FactoryGirl.create(:course,
                                      mooc_provider_id: provider.id) }
  let!(:course3) { FactoryGirl.create(:course,
                                      mooc_provider_id: provider.id) }
  let!(:wrong_dates_course) { FactoryGirl.create(:course,
                                      mooc_provider_id: provider.id,
                                      start_date: DateTime.new(2015,10,15),
                                      end_date: DateTime.new(2015,03,17)) }

  it "should set duration after creation" do
    expect(course1.calculated_duration_in_days).to eq(2)
  end

  it "should update duration after update of start/end_time" do
    course1.end_date = DateTime.new(2015,04,16)
    course1.save
    expect(course1.calculated_duration_in_days).to eq(32)
  end

  it "should save corresponding course, when setting previous_iteration_id" do
    course1.previous_iteration_id = course2.id
    course1.save
    expect(Course.find(course2.id).following_iteration_id).to eql course1.id
  end

  it "should save corresponding course, when setting following_iteration_id" do
    course1.following_iteration_id = course3.id
    course1.save
    expect(Course.find(course3.id).previous_iteration_id).to eql course1.id
  end

  it "should delete corresponding course connections, when destroying course" do
    course1.previous_iteration_id = course2.id
    course1.following_iteration_id = course3.id
    course1.save
    course1.destroy
    expect(Course.find(course3.id).previous_iteration_id).to eql nil
    expect(Course.find(course2.id).following_iteration_id).to eql nil
  end

  it "should set an existing end_date to nil, if the end_date is chronologically before the start date" do
    expect(Course.find(wrong_dates_course.id).end_date).to eql nil
  end

  it "should reject data, if it has_no tracks" do
    course1.tracks = []
    expect{course1.save!}.to raise_error ActiveRecord::RecordInvalid
    expect{Course.create!}.to raise_error ActiveRecord::RecordInvalid
  end

  it "should save data, if it has at least on track" do
    course1.tracks.push(FactoryGirl.create(:course_track))
    expect{course1.save!}.not_to raise_error
  end

end
