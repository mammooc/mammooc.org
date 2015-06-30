# -*- encoding : utf-8 -*-
require 'rails_helper'

RSpec.describe Course, type: :model do
  describe 'bookmarked_by_user' do
    it 'delivers true if bookmarked by user' do
      user = FactoryGirl.create(:user)
      bookmark = FactoryGirl.create(:bookmark, user: user)
      expect(
        bookmark.course.bookmarked_by_user? user
      ).to be true
    end

    it 'delivers false if not bookmarked by this user' do
      user = FactoryGirl.create(:user)
      bookmark = FactoryGirl.create(:bookmark)
      expect(
        bookmark.course.bookmarked_by_user? user
      ).to be false
    end
  end

  describe 'saving a course' do
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

  describe 'update_course_rating_attributes' do
    let!(:course) { FactoryGirl.create(:course) }

    it 'update calculated rating and rating count' do
      FactoryGirl.create(:full_evaluation, rating: 1, course: course)
      FactoryGirl.create(:minimal_evaluation, rating: 5, course: course)
      course.reload
      expect(course.rating_count).to eq(2)
      expect(course.calculated_rating).to eq(3.0)
    end

    it 'set calculated rating and rating count to zero when evaluations are deleted' do
      eva1 = FactoryGirl.create(:full_evaluation, rating: 1, course: course)
      eva2 = FactoryGirl.create(:minimal_evaluation, rating: 5, course: course)
      eva1.destroy
      eva2.destroy
      course.reload
      expect(course.rating_count).to eq(0)
      expect(course.calculated_rating).to eq(0.0)
    end
  end

  describe 'options for different attributes' do
    it 'returns an array of options for costs' do
      options = described_class.options_for_costs
      expect(options).to be_a Array
      expect(options).to include([I18n.t('courses.filter.costs.free'), 'free'])
    end

    it 'returs an array of options for start categories' do
      options = described_class.options_for_start
      expect(options).to be_a Array
      expect(options).to include([I18n.t('courses.filter.start.now'), 'now'])
    end

    it 'returns an array of options for duration' do
      options = described_class.options_for_duration
      expect(options).to be_a Array
      expect(options).to include([I18n.t('courses.filter.duration.short'), 'short'])
    end

    it 'returns an array of options for languages' do
      options = described_class.options_for_languages
      expect(options).to be_a Array
      expect(options).to include([I18n.t('language.en'), 'en'])
    end

    it 'returns an array of options for subtitle_languages' do
      options = described_class.options_for_subtitle_languages
      expect(options).to be_a Array
      expect(options).to include([I18n.t('language.en'), 'en'])
    end
  end

  describe 'scopes for filtering' do
    context 'sorted_by' do
      let!(:course_today) { FactoryGirl.create(:course, name: 'AAA', calculated_duration_in_days: 800, start_date: Time.zone.now) }
      let!(:course_soon) { FactoryGirl.create(:course, name: 'ZZZ', calculated_duration_in_days: 60, start_date: Time.zone.now + 1.weeks) }
      let!(:course_current) { FactoryGirl.create(:course, name: 'CCC', start_date: Time.zone.now - 1.weeks, end_date: Time.zone.now + 1.weeks) } # calculated_duration_in_days will be 14
      let!(:course_past) { FactoryGirl.create(:course, name: 'BBB', start_date: Time.zone.now - 4.weeks, end_date: Time.zone.now - 1.weeks) } # calculated_duration_in_days will be 21
      let!(:course_without_dates) { FactoryGirl.create(:course, name: 'FFF', start_date: nil, end_date: nil) }

      it 'sorts for name asc' do
        result = described_class.sorted_by('name_asc')
        expect(result).to match([course_today, course_past, course_current, course_without_dates, course_soon])
      end

      it 'sorts for name desc' do
        result = described_class.sorted_by('name_desc')
        expect(result).to match([course_soon, course_without_dates, course_current, course_past, course_today])
      end

      it 'sorts for duration asc' do
        result = described_class.sorted_by('duration_asc')
        expect(result).to match([course_current, course_past, course_soon, course_today, course_without_dates])
      end

      it 'sorts for duration desc' do
        result = described_class.sorted_by('duration_desc')
        expect(result).to match([course_today, course_soon, course_past, course_current, course_without_dates])
      end

      it 'sorts for start_date_asc' do
        result = described_class.sorted_by('start_date_asc')
        expect(result).to match([course_past, course_current, course_today, course_soon, course_without_dates])
      end

      it 'sorts for start_date_desc' do
        result = described_class.sorted_by('start_date_desc')
        expect(result).to match([course_soon, course_today, course_current, course_past, course_without_dates])
      end

      it 'show relevant courses starts current first' do
        result = described_class.sorted_by('relevance_asc')
        expect(result).to match([course_current, course_today, course_soon, course_past, course_without_dates])
      end
    end

    context 'search query' do
      let!(:course_match_name) { FactoryGirl.create(:course, name: 'Web Technologies') }
      let!(:course_not_match_name) { FactoryGirl.create(:course, name: 'Wob Technochicks') }
      let!(:course_match_instructors) { FactoryGirl.create(:course, name: 'Java course', course_instructors: 'Jan Renz, Thomas Staubitz') }
      let!(:course_not_match_instructors) { FactoryGirl.create(:course, name: 'Ruby course', course_instructors: 'Prof. Dr. Christoph Meinel, Erwin Abitz') }

      it 'finds the course with the specified name' do
        result = described_class.search_query(course_match_name.name)
        expect(result).to match_array([course_match_name])
      end

      it 'finds courses with the specified course instructor' do
        result = described_class.search_query(course_match_instructors.course_instructors)
        expect(result).to match_array([course_match_instructors])
      end

      it 'finds courses where query match first part of course name' do
        result = described_class.search_query('We')
        expect(result).to match_array([course_match_name])
      end

      it 'finds courses where query match last part of course name' do
        result = described_class.search_query('gies')
        expect(result).to match_array([course_match_name])
      end

      it 'finds courses where query match middle part of course name' do
        result = described_class.search_query('Techno')
        expect(result).to match_array([course_match_name, course_not_match_name])
      end

      it 'finds courses where query match first part of course instructors' do
        result = described_class.search_query('Jan')
        expect(result).to match_array([course_match_instructors])
      end

      it 'finds courses where query match last part of course instructors' do
        result = described_class.search_query('bitz')
        expect(result).to match_array([course_match_instructors, course_not_match_instructors])
      end

      it 'finds courses where query match middle part of course instructors' do
        result = described_class.search_query('Chris')
        expect(result).to match_array([course_not_match_instructors])
      end

      it 'treats upper and lowercase equally' do
        result = described_class.search_query('JAN')
        expect(result).to match_array([course_match_instructors])
      end
    end

    context 'with_start_date_gte' do
      let(:test_date) { '05.04.2015' }
      let!(:wrong_course) { FactoryGirl.create(:course, start_date: Time.zone.parse(test_date) - 1.day) }
      let!(:correct_course) { FactoryGirl.create(:course, start_date: Time.zone.parse(test_date)) }
      let!(:correct_course2) { FactoryGirl.create(:course, start_date: Time.zone.parse(test_date) + 1.week) }

      it 'returns courses that start at or after defined date' do
        result = described_class.with_start_date_gte(test_date)
        expect(result).to match_array([correct_course, correct_course2])
      end

      it 'ignores courses without start_date' do
        wrong_course.start_date = nil
        wrong_course.save
        result = described_class.with_start_date_gte(test_date)
        expect(result).to match_array([correct_course, correct_course2])
      end
    end

    context 'with_end_date_gte' do
      let(:test_date) { '05.04.2015' }
      let!(:wrong_course) { FactoryGirl.create(:course, end_date: Time.zone.parse(test_date) + 1.day) }
      let!(:correct_course) { FactoryGirl.create(:course, end_date: Time.zone.parse(test_date)) }
      let!(:correct_course2) { FactoryGirl.create(:course, end_date: Time.zone.parse(test_date) - 1.week) }

      it 'returns courses that end at or before defined date' do
        result = described_class.with_end_date_lte(test_date)
        expect(result).to match_array([correct_course, correct_course2])
      end

      it 'ignores courses without end_date' do
        wrong_course.end_date = nil
        wrong_course.save
        result = described_class.with_end_date_lte(test_date)
        expect(result).to match_array([correct_course, correct_course2])
      end
    end

    context 'with_language' do
      let(:test_language) { 'en' }
      let!(:wrong_course) { FactoryGirl.create(:course, language: 'ru') }
      let!(:correct_course) { FactoryGirl.create(:course, language: test_language) }
      let!(:correct_course2) { FactoryGirl.create(:course, language: test_language) }

      it 'returns courses that have only the test language set as language' do
        result = described_class.with_language(test_language)
        expect(result).to match_array([correct_course, correct_course2])
      end

      it 'ignores courses without language' do
        wrong_course.language = nil
        wrong_course.save
        result = described_class.with_language(test_language)
        expect(result).to match_array([correct_course, correct_course2])
      end

      it 'works with languages that define a region' do
        correct_course.language = "#{test_language}-gb"
        correct_course.save
        result = described_class.with_language(test_language)
        expect(result).to match_array([correct_course2, correct_course])
      end

      it 'works with the search language being one of the later languages' do
        correct_course.language = "zh,#{test_language}"
        correct_course.save
        result = described_class.with_language(test_language)
        expect(result).to match_array([correct_course2, correct_course])
      end

      it 'works with the search language being the first of many languages' do
        correct_course.language = "#{test_language},zh"
        correct_course.save
        result = described_class.with_language(test_language)
        expect(result).to match_array([correct_course2, correct_course])
      end

      it 'works with multiple languages that include regions' do
        correct_course.language = "de,#{test_language}-gb,zh"
        correct_course.save
        result = described_class.with_language(test_language)
        expect(result).to match_array([correct_course2, correct_course])
      end
    end

    context 'with_end_date_gte' do
      let!(:wrong_provider) { FactoryGirl.create(:mooc_provider) }
      let!(:correct_provider) { FactoryGirl.create(:mooc_provider) }
      let!(:wrong_provider2) { FactoryGirl.create(:mooc_provider) }
      let!(:wrong_course) { FactoryGirl.create(:course, mooc_provider: wrong_provider) }
      let!(:correct_course) { FactoryGirl.create(:course, mooc_provider: correct_provider) }
      let!(:wrong_course2) { FactoryGirl.create(:course, mooc_provider: wrong_provider2) }

      it 'returns courses of the correct provider' do
        result = described_class.with_mooc_provider_id(correct_provider.id)
        expect(result).to match_array([correct_course])
      end
    end

    context 'with_subtitle_language' do
      let(:test_language) { 'en' }
      let!(:wrong_course) { FactoryGirl.create(:course, subtitle_languages: 'ru') }
      let!(:correct_course) { FactoryGirl.create(:course, subtitle_languages: test_language) }
      let!(:correct_course2) { FactoryGirl.create(:course, subtitle_languages: test_language) }

      it 'returns courses that have only the test subtitle_language set as subtitle_language' do
        result = described_class.with_subtitle_languages(test_language)
        expect(result).to match_array([correct_course, correct_course2])
      end

      it 'ignores courses without subtitle_language' do
        wrong_course.subtitle_languages = nil
        wrong_course.save
        result = described_class.with_subtitle_languages(test_language)
        expect(result).to match_array([correct_course, correct_course2])
      end

      it 'works with subtitle_languages that define a region' do
        correct_course.subtitle_languages = "#{test_language}-gb"
        correct_course.save
        result = described_class.with_subtitle_languages(test_language)
        expect(result).to match_array([correct_course2, correct_course])
      end

      it 'works with the search subtitle_language being one of the later subtitle_languages' do
        correct_course.subtitle_languages = "zh,#{test_language}"
        correct_course.save
        result = described_class.with_subtitle_languages(test_language)
        expect(result).to match_array([correct_course2, correct_course])
      end

      it 'works with the search subtitle_language being the first of many subtitle_languages' do
        correct_course.subtitle_languages = "#{test_language},zh"
        correct_course.save
        result = described_class.with_subtitle_languages(test_language)
        expect(result).to match_array([correct_course2, correct_course])
      end

      it 'works with multiple subtitle_languages that include regions' do
        correct_course.subtitle_languages = "de,#{test_language}-gb,zh"
        correct_course.save
        result = described_class.with_subtitle_languages(test_language)
        expect(result).to match_array([correct_course2, correct_course])
      end
    end

    context 'start_filter_options' do
      let(:current_date) { Time.zone.now.strftime('%d.%m.%Y').to_s }
      let!(:current_course) { FactoryGirl.create(:course, start_date: Time.zone.parse(current_date), end_date: Time.zone.parse(current_date) + 2.weeks) }
      let!(:past_course) { FactoryGirl.create(:course, start_date: Time.zone.parse(current_date) - 4.weeks, end_date: Time.zone.parse(current_date) - 2.weeks) }
      let!(:soon_course) { FactoryGirl.create(:course, start_date: Time.zone.parse(current_date) + 1.weeks, end_date: Time.zone.parse(current_date) + 3.weeks) }
      let!(:future_course) { FactoryGirl.create(:course, start_date: Time.zone.parse(current_date) + 4.weeks, end_date: Time.zone.parse(current_date) + 6.weeks) }
      let!(:without_start_course) { FactoryGirl.create(:course, start_date: nil, end_date: Time.zone.parse(current_date) + 3.weeks) }
      let!(:without_end_course) { FactoryGirl.create(:course, start_date: Time.zone.parse(current_date), end_date: nil) }
      let!(:without_dates_course) { FactoryGirl.create(:course, start_date: nil, end_date: nil) }

      it 'returns the courses that are currently running' do
        result = described_class.start_filter_options('now')
        expect(result).to match([current_course])
      end

      it 'returns the courses that were running in the past' do
        result = described_class.start_filter_options('past')
        expect(result).to match([past_course])
      end

      it 'returns the courses that starts soon' do
        result = described_class.start_filter_options('soon')
        expect(result).to match([soon_course])
      end

      it 'returns the courses that starts in the future' do
        result = described_class.start_filter_options('future')
        expect(result).to match([future_course])
      end

      context 'courses without end_date but with duration' do
        before(:each) do
          current_course.end_date = nil
          past_course.end_date = nil
          soon_course.end_date = nil
          future_course.end_date = nil
          current_course.save
          past_course.save
          soon_course.save
          future_course.save
        end

        it 'returns the courses that are currently running ' do
          result = described_class.start_filter_options('now')
          expect(result).to match([current_course])
        end

        it 'returns the courses that were running in the past' do
          result = described_class.start_filter_options('past')
          expect(result).to match([past_course])
        end

        it 'returns the courses that starts soon' do
          result = described_class.start_filter_options('soon')
          expect(result).to match([soon_course])
        end

        it 'returns the courses that starts in the future' do
          result = described_class.start_filter_options('future')
          expect(result).to match([future_course])
        end
      end
    end

    context 'duration_filter_options' do
      let(:current_date) { Time.zone.now.strftime('%d.%m.%Y').to_s }
      let!(:short_course) { FactoryGirl.create(:course, start_date: Time.zone.parse(current_date), end_date: Time.zone.parse(current_date) + 2.weeks) }
      let!(:short_medium_course) { FactoryGirl.create(:course, start_date: Time.zone.parse(current_date), end_date: Time.zone.parse(current_date) + 5.weeks) }
      let!(:medium_course) { FactoryGirl.create(:course, start_date: Time.zone.parse(current_date), end_date: Time.zone.parse(current_date) + 7.weeks) }
      let!(:medium_long_course) { FactoryGirl.create(:course, start_date: Time.zone.parse(current_date), end_date: Time.zone.parse(current_date) + 11.weeks) }
      let!(:long_course) { FactoryGirl.create(:course, start_date: Time.zone.parse(current_date), end_date: Time.zone.parse(current_date) + 13.weeks) }
      let!(:course_without_duration) { FactoryGirl.create(:course, start_date: nil, end_date: nil) }

      it 'returns short course' do
        result = described_class.duration_filter_options('short')
        expect(result).to match([short_course])
      end

      it 'returns short-medium course' do
        result = described_class.duration_filter_options('short-medium')
        expect(result).to match([short_medium_course])
      end

      it 'returns medium course' do
        result = described_class.duration_filter_options('medium')
        expect(result).to match([medium_course])
      end

      it 'returns medium-long course' do
        result = described_class.duration_filter_options('medium-long')
        expect(result).to match([medium_long_course])
      end

      it 'returns long course' do
        result = described_class.duration_filter_options('long')
        expect(result).to match([long_course])
      end
    end

    context 'with_tracks' do
      let(:track_options) { {costs: nil, certificate: nil} }

      context 'only costs' do
        let(:free_track) { FactoryGirl.create(:free_course_track) }
        let(:track1) { FactoryGirl.create(:certificate_course_track, costs: 20.0) }
        let(:track2) { FactoryGirl.create(:certificate_course_track, costs: 40.0) }
        let(:track3) { FactoryGirl.create(:certificate_course_track, costs: 70.0) }
        let(:track4) { FactoryGirl.create(:certificate_course_track, costs: 100.0) }
        let(:track5) { FactoryGirl.create(:certificate_course_track, costs: 160.0) }
        let(:track6) { FactoryGirl.create(:certificate_course_track, costs: 210.0) }

        let!(:free_course) { FactoryGirl.create(:course, tracks: [free_track]) }
        let!(:course_range1) { FactoryGirl.create(:course, tracks: [track1]) }
        let!(:course_range2) { FactoryGirl.create(:course, tracks: [track2]) }
        let!(:course_range3) { FactoryGirl.create(:course, tracks: [track3]) }
        let!(:course_range4) { FactoryGirl.create(:course, tracks: [track4]) }
        let!(:course_range5) { FactoryGirl.create(:course, tracks: [track5]) }
        let!(:course_range6) { FactoryGirl.create(:course, tracks: [track6]) }
        let!(:course_undefined_costs) { FactoryGirl.create(:course) }

        it 'returns free course' do
          track_options[:costs] = 'free'
          result = described_class.with_tracks(track_options)
          expect(result).to match([free_course])
        end

        it 'returns course where costs match first range' do
          track_options[:costs] = 'range1'
          result = described_class.with_tracks(track_options)
          expect(result).to match([course_range1])
        end

        it 'returns course where costs match second range' do
          track_options[:costs] = 'range2'
          result = described_class.with_tracks(track_options)
          expect(result).to match([course_range2])
        end

        it 'returns course where costs match third range' do
          track_options[:costs] = 'range3'
          result = described_class.with_tracks(track_options)
          expect(result).to match([course_range3])
        end

        it 'returns course where costs match fourth range' do
          track_options[:costs] = 'range4'
          result = described_class.with_tracks(track_options)
          expect(result).to match([course_range4])
        end

        it 'returns course where costs match fifth range' do
          track_options[:costs] = 'range5'
          result = described_class.with_tracks(track_options)
          expect(result).to match([course_range5])
        end

        it 'returns course where costs match sixth range' do
          track_options[:costs] = 'range6'
          result = described_class.with_tracks(track_options)
          expect(result).to match([course_range6])
        end
      end

      context 'only certificate' do
        let(:track_type1) { FactoryGirl.create(:course_track_type) }
        let(:track_type2) { FactoryGirl.create(:course_track_type) }

        let(:track1) { FactoryGirl.create(:certificate_course_track, track_type: track_type1) }
        let(:track2) { FactoryGirl.create(:certificate_course_track, track_type: track_type2) }

        let!(:course1) { FactoryGirl.create(:course, tracks: [track1]) }
        let!(:course2) { FactoryGirl.create(:course, tracks: [track2]) }

        it 'returns course with defined certificate' do
          track_options[:certificate] = track_type1.id
          result = described_class.with_tracks(track_options)
          expect(result).to match([course1])
        end
      end

      context 'costs and certificate' do
        let(:track_type1) { FactoryGirl.create(:course_track_type) }
        let(:track_type2) { FactoryGirl.create(:course_track_type) }

        let(:free_track1) { FactoryGirl.create(:free_course_track, track_type: track_type1) }
        let(:free_track2) { FactoryGirl.create(:free_course_track, track_type: track_type2) }

        let(:track1_range1) { FactoryGirl.create(:certificate_course_track, costs: 20.0, track_type: track_type1) }
        let(:track2_range1) { FactoryGirl.create(:certificate_course_track, costs: 20.0, track_type: track_type2) }

        let(:track1_range2) { FactoryGirl.create(:certificate_course_track, costs: 40.0, track_type: track_type1) }
        let(:track2_range2) { FactoryGirl.create(:certificate_course_track, costs: 40.0, track_type: track_type2) }

        let(:track1_range3) { FactoryGirl.create(:certificate_course_track, costs: 70.0, track_type: track_type1) }
        let(:track2_range3) { FactoryGirl.create(:certificate_course_track, costs: 70.0, track_type: track_type2) }

        let(:track1_range4) { FactoryGirl.create(:certificate_course_track, costs: 100.0, track_type: track_type1) }
        let(:track2_range4) { FactoryGirl.create(:certificate_course_track, costs: 100.0, track_type: track_type2) }

        let(:track1_range5) { FactoryGirl.create(:certificate_course_track, costs: 160.0, track_type: track_type1) }
        let(:track2_range5) { FactoryGirl.create(:certificate_course_track, costs: 160.0, track_type: track_type2) }

        let(:track1_range6) { FactoryGirl.create(:certificate_course_track, costs: 210.0, track_type: track_type1) }
        let(:track2_range6) { FactoryGirl.create(:certificate_course_track, costs: 210.0, track_type: track_type2) }

        let!(:free1_course) { FactoryGirl.create(:course, tracks: [free_track1]) }
        let!(:free2_course) { FactoryGirl.create(:course, tracks: [free_track2]) }

        let!(:course1_range1) { FactoryGirl.create(:course, tracks: [track1_range1]) }
        let!(:course2_range1) { FactoryGirl.create(:course, tracks: [track2_range1]) }

        let!(:course1_range2) { FactoryGirl.create(:course, tracks: [track1_range2]) }
        let!(:course2_range2) { FactoryGirl.create(:course, tracks: [track2_range2]) }

        let!(:course1_range3) { FactoryGirl.create(:course, tracks: [track1_range3]) }
        let!(:course2_range3) { FactoryGirl.create(:course, tracks: [track2_range3]) }

        let!(:course1_range4) { FactoryGirl.create(:course, tracks: [track1_range4]) }
        let!(:course2_range4) { FactoryGirl.create(:course, tracks: [track2_range4]) }

        let!(:course1_range5) { FactoryGirl.create(:course, tracks: [track1_range5]) }
        let!(:course2_range5) { FactoryGirl.create(:course, tracks: [track2_range5]) }

        let!(:course1_range6) { FactoryGirl.create(:course, tracks: [track1_range6]) }
        let!(:course2_range6) { FactoryGirl.create(:course, tracks: [track2_range6]) }

        let!(:course_undefined_costs) { FactoryGirl.create(:course) }

        it 'returns free courses with defined certificate' do
          track_options[:costs] = 'free'
          track_options[:certificate] = track_type1.id
          result = described_class.with_tracks(track_options)
          expect(result).to match([free1_course])
        end

        it 'returns courses with defined certificate course where costs match first range' do
          track_options[:costs] = 'range1'
          track_options[:certificate] = track_type1.id
          result = described_class.with_tracks(track_options)
          expect(result).to match([course1_range1])
        end

        it 'returns courses with defined certificate course where costs match second range' do
          track_options[:costs] = 'range2'
          track_options[:certificate] = track_type1.id
          result = described_class.with_tracks(track_options)
          expect(result).to match([course1_range2])
        end

        it 'returns courses with defined certificate course where costs match third range' do
          track_options[:costs] = 'range3'
          track_options[:certificate] = track_type1.id
          result = described_class.with_tracks(track_options)
          expect(result).to match([course1_range3])
        end

        it 'returns courses with defined certificate course where costs match fourth range' do
          track_options[:costs] = 'range4'
          track_options[:certificate] = track_type1.id
          result = described_class.with_tracks(track_options)
          expect(result).to match([course1_range4])
        end

        it 'returns courses with defined certificate course where costs match fifth range' do
          track_options[:costs] = 'range5'
          track_options[:certificate] = track_type1.id
          result = described_class.with_tracks(track_options)
          expect(result).to match([course1_range5])
        end

        it 'returns courses with defined certificate course where costs match sixth range' do
          track_options[:costs] = 'range6'
          track_options[:certificate] = track_type1.id
          result = described_class.with_tracks(track_options)
          expect(result).to match([course1_range6])
        end
      end
    end

    context 'my bookmarked courses' do
      let(:user) { FactoryGirl.create(:user) }
      let(:second_user) { FactoryGirl.create(:user) }
      let(:not_bookmarked_course) { FactoryGirl.create(:course) }
      let(:bookmarked_course) { FactoryGirl.create(:course) }
      let!(:bookmark) { FactoryGirl.create(:bookmark, user: user, course: bookmarked_course) }

      it 'returns only bookmarked courses' do
        result = described_class.bookmarked(user.id)
        expect(result).to match([bookmarked_course])
      end

      it 'returns nothing if there are no bookmarked courses' do
        result = described_class.bookmarked(second_user.id)
        expect(result).to match([])
      end
    end
  end

  describe 'destroys a course' do
    let!(:course) { FactoryGirl.create(:course) }

    it 'destroys all activities where course is referenced' do
      bookmark = FactoryGirl.create(:bookmark, course: course)
      FactoryGirl.create(:activity_bookmark, trackable_id: bookmark.id)

      FactoryGirl.create(:activity_course_enroll, trackable_id: course.id)

      group_recommendation = FactoryGirl.create(:group_recommendation_without_activity, course: course)
      FactoryGirl.create(:activity, trackable_id: group_recommendation.id, trackable_type: 'Recommendation')

      user_recommendation = FactoryGirl.create(:user_recommendation_without_activity, course: course)
      FactoryGirl.create(:activity, trackable_id: user_recommendation.id, trackable_type: 'Recommendation')

      expect(PublicActivity::Activity.count).to eq 4
      expect { course.destroy! }.not_to raise_error
      expect(PublicActivity::Activity.count).to eq 0
    end

    it 'does not destroy activities where course is not referenced' do
      FactoryGirl.create(:activity_bookmark)
      FactoryGirl.create(:activity_course_enroll)
      FactoryGirl.create(:activity_group_recommendation)
      FactoryGirl.create(:activity_user_recommendation)

      expect(PublicActivity::Activity.count).to eq 4
      expect { course.destroy! }.not_to raise_error
      expect(PublicActivity::Activity.count).to eq 4
    end
  end
end
