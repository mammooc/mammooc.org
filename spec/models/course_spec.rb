# -*- encoding : utf-8 -*-
require 'rails_helper'

RSpec.describe Course, type: :model do
  let!(:provider) { FactoryGirl.create(:mooc_provider) }
  let!(:course1) do
    FactoryGirl.create(:course,
      mooc_provider_id: provider.id,
      start_date: Time.zone.local(2015, 03, 15),
      end_date: Time.zone.local(2015, 03, 17),
      provider_course_id: '123')
  end
  let!(:course2) do
    FactoryGirl.create(:course,
      mooc_provider_id: provider.id)
  end
  let!(:course3) do
    FactoryGirl.create(:course,
      mooc_provider_id: provider.id)
  end
  let!(:wrong_dates_course) do
    FactoryGirl.create(:course,
      mooc_provider_id: provider.id,
      start_date: Time.zone.local(2015, 10, 15),
      end_date: Time.zone.local(2015, 03, 17))
  end

  it 'sets duration after creation' do
    expect(course1.calculated_duration_in_days).to eq(2)
  end

  it 'updates duration after update of start/end_time' do
    course1.end_date = Time.zone.local(2015, 04, 16)
    course1.save
    expect(course1.calculated_duration_in_days).to eq(32)
  end

  it 'saves corresponding course, when setting previous_iteration_id' do
    course1.previous_iteration_id = course2.id
    course1.save
    expect(described_class.find(course2.id).following_iteration_id).to eql course1.id
  end

  it 'saves corresponding course, when setting following_iteration_id' do
    course1.following_iteration_id = course3.id
    course1.save
    expect(described_class.find(course3.id).previous_iteration_id).to eql course1.id
  end

  it 'deletes corresponding course connections, when destroying course' do
    course1.previous_iteration_id = course2.id
    course1.following_iteration_id = course3.id
    course1.save
    course1.destroy
    expect(described_class.find(course3.id).previous_iteration_id).to eql nil
    expect(described_class.find(course2.id).following_iteration_id).to eql nil
  end

  it 'sets an existing end_date to nil, if the end_date is chronologically before the start date' do
    expect(described_class.find(wrong_dates_course.id).end_date).to eql nil
  end

  it 'rejects data, if it has_no tracks' do
    course1.tracks = []
    expect { course1.save! }.to raise_error ActiveRecord::RecordInvalid
    expect { described_class.create! }.to raise_error ActiveRecord::RecordInvalid
  end

  it 'saves data, if it has at least on track' do
    course1.tracks.push(FactoryGirl.create(:course_track))
    expect { course1.save! }.not_to raise_error
  end

  it 'returns our course id for a given mooc provider and its provider course id' do
    course_id = described_class.get_course_id_by_mooc_provider_id_and_provider_course_id provider, '123'
    expect(course_id).to eq course1.id
  end

  it 'returns nil for an invalid set of mooc provider and its provider course id' do
    course_id = described_class.get_course_id_by_mooc_provider_id_and_provider_course_id provider, '456'
    expect(course_id).to eq nil
  end
end
