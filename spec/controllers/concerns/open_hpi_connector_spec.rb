# encoding: utf-8
# frozen_string_literal: true
require 'rails_helper'

RSpec.describe OpenHPIConnector do
  let!(:mooc_provider) { FactoryGirl.create(:mooc_provider, name: 'openHPI', api_support_state: 'naive') }
  let!(:user) { FactoryGirl.create(:user) }
  let(:open_hpi_connector) { described_class.new }

  describe 'mooc_provider' do
    it 'delivers MOOCProvider' do
      expect(open_hpi_connector.send(:mooc_provider)).to eql mooc_provider
    end
  end

  describe 'get access token' do
    it 'returns nil when user has no connection to mooc provider' do
      expect(open_hpi_connector.send(:get_access_token, user)).to eql nil
    end

    it 'returns access_token when user has connection to mooc provider' do
      FactoryGirl.create(:naive_mooc_provider_user, user: user, mooc_provider: mooc_provider, access_token: '123')
      expect(open_hpi_connector.send(:get_access_token, user)).to eql '123'
    end
  end

  describe 'connection to mooc provider' do
    it 'returns false when user has no connection to mooc provider' do
      expect(open_hpi_connector.connection_to_mooc_provider?(user)).to eql false
    end

    it 'returns true when user has connection to mooc provider' do
      user.mooc_providers << mooc_provider
      expect(open_hpi_connector.connection_to_mooc_provider?(user)).to eql true
    end
  end

  describe 'initialize connection' do
    let(:credentials) { {email: 'blub@blub.blub', password: 'blubblub'} }

    it 'creates MoocProvider-User connection, when request is answered with token' do
      allow(RestClient).to receive(:post).and_return('{"token":"1234567890"}')
      expect { open_hpi_connector.initialize_connection(user, credentials) }.to change { MoocProviderUser.count }.by(1)
    end

    it 'updates MoocProvider-User connection, when a token is already present and the request is answered with token' do
      FactoryGirl.create(:naive_mooc_provider_user, user: user, mooc_provider: mooc_provider, access_token: '123')
      expect(open_hpi_connector.send(:get_access_token, user)).to eql '123'
      allow(RestClient).to receive(:post).and_return('{"token":"1234567890"}')
      expect { open_hpi_connector.initialize_connection(user, credentials) }.to change { MoocProviderUser.count }.by(0)
      expect(open_hpi_connector.send(:get_access_token, user)).to eql '1234567890'
    end

    it 'does not create MoocProvider-User connection, when request is answered with empty token' do
      allow(RestClient).to receive(:post).and_return('{"token":""}')
      expect { open_hpi_connector.initialize_connection(user, credentials) }.to change { MoocProviderUser.count }.by(0)
    end

    it 'handles internal server error for token request' do
      user.mooc_providers << mooc_provider
      allow(open_hpi_connector).to receive(:send_connection_request).and_raise RestClient::InternalServerError
      expect { open_hpi_connector.initialize_connection(user, credentials) }.not_to raise_error
    end
  end

  describe 'destroy connection' do
    it 'destroys MoocProvider-User connection, when it is present' do
      user.mooc_providers << mooc_provider
      expect { open_hpi_connector.destroy_connection(user) }.to change { MoocProviderUser.count }.by(-1)
    end

    it 'does not try to destroy MoocProvider-User connection, when it is not present' do
      expect(open_hpi_connector.destroy_connection(user)).to eql false
    end
  end

  context 'synchronize user enrollments' do
    let!(:course) { FactoryGirl.create(:full_course, provider_course_id: '0c6c5ad1-a770-4f16-81c3-536169f3cbd3', mooc_provider_id: mooc_provider.id) }
    let!(:second_course) { FactoryGirl.create(:full_course, provider_course_id: 'bccf2ca2-429c-4cd0-9f63-caaccf85727a', mooc_provider_id: mooc_provider.id) }

    let(:enrollment_data) do
      '[{"id":"dfcfdf0f-e0ad-4887-abfa-83cc233c291f","course_id":"c5600abf-5abf-460b-ba6f-1d030053fd79"},{"id":"bbc4c2a7-51ed-460a-a312-6ba4b3da3545","course_id":"0c6c5ad1-a770-4f16-81c3-536169f3cbd3"},{"id":"48edd6a8-3a9a-4a64-8b5c-631142022d15","course_id":"bccf2ca2-429c-4cd0-9f63-caaccf85727a"}]'
    end

    let(:json_enrollment_data) do
      JSON.parse enrollment_data
    end

    describe 'get enrollments for user' do
      it 'gets an API response' do
        FactoryGirl.create(:naive_mooc_provider_user, user: user, mooc_provider: mooc_provider, access_token: '123')
        expect { open_hpi_connector.send(:get_enrollments_for_user, user) }.to raise_error RestClient::InternalServerError
      end

      it 'returns parsed response for enrolled courses' do
        FactoryGirl.create(:naive_mooc_provider_user, user: user, mooc_provider: mooc_provider, access_token: '123')
        allow(RestClient).to receive(:get).and_return(enrollment_data)
        expect(open_hpi_connector.send(:get_enrollments_for_user, user)).to eql json_enrollment_data
      end
    end

    describe 'handle enrollments response' do
      it 'loads new enrollment into database' do
        expect do
          open_hpi_connector.send(:handle_enrollments_response, json_enrollment_data, user)
        end.to change(user.courses, :count).by(2)
      end

      it 'adds course enrollment into database' do
        user.courses << second_course
        open_hpi_connector.send(:handle_enrollments_response, json_enrollment_data, user)

        json_enrollment = json_enrollment_data[1]
        enrolled_course = Course.get_course_by_mooc_provider_id_and_provider_course_id mooc_provider.id, json_enrollment['course_id']
        enrollment_array = user.courses.where(id: enrolled_course.id)
        expect(enrollment_array).not_to be_empty
        expect(user.courses).to contain_exactly(course, second_course)
      end
    end

    describe 'enroll user for course' do
      it 'returns nil when trying to enroll and user has no mooc provider connection' do
        expect(open_hpi_connector.enroll_user_for_course(user, course)).to eql nil
      end

      it 'returns false when trying to enroll and user has mooc provider connection but something went wrong' do
        user.mooc_providers << mooc_provider
        allow(RestClient).to receive(:post).and_raise RestClient::Unauthorized
        expect(open_hpi_connector.enroll_user_for_course(user, course)).to eql false
      end

      it 'returns true when trying to enroll and everything was ok' do
        user.mooc_providers << mooc_provider
        allow(RestClient).to receive(:post).and_return('{"success"}')
        expect(open_hpi_connector.enroll_user_for_course(user, course)).to eql true
      end

      it 'handles internal server error for course enrollments' do
        user.mooc_providers << mooc_provider
        allow(open_hpi_connector).to receive(:send_enrollment_for_course).and_raise RestClient::InternalServerError
        expect { open_hpi_connector.enroll_user_for_course(user, course) }.not_to raise_error
      end
    end

    describe 'unenroll user for course' do
      it 'returns nil when trying to unenroll and user has no mooc provider connection' do
        expect(open_hpi_connector.unenroll_user_for_course(user, course)).to eql nil
      end

      it 'returns false when trying to unenroll and user has mooc provider connection but something went wrong' do
        user.mooc_providers << mooc_provider
        allow(RestClient).to receive(:delete).and_raise RestClient::Unauthorized
        expect(open_hpi_connector.unenroll_user_for_course(user, course)).to eql false
      end

      it 'returns true when trying to unenroll and everything was ok' do
        user.mooc_providers << mooc_provider
        allow(RestClient).to receive(:delete).and_return('{"success"}')
        expect(open_hpi_connector.unenroll_user_for_course(user, course)).to eql true
      end

      it 'handles internal server error for course unenrollments' do
        user.mooc_providers << mooc_provider
        allow(open_hpi_connector).to receive(:send_unenrollment_for_course).and_raise RestClient::InternalServerError
        expect { open_hpi_connector.unenroll_user_for_course(user, course) }.not_to raise_error
      end
    end

    describe 'load user data' do
      it 'loads specified user data for a given user' do
        FactoryGirl.create(:naive_mooc_provider_user, user: user, mooc_provider: mooc_provider, access_token: '123')
        allow(RestClient).to receive(:get).and_return(enrollment_data)
        expect { open_hpi_connector.load_user_data([user]) }.not_to raise_error
        expect(user.courses.count).to eql 2
      end

      it 'loads specified user data for all users' do
        second_user = FactoryGirl.create(:user)
        FactoryGirl.create(:naive_mooc_provider_user, user: user, mooc_provider: mooc_provider, access_token: '123')
        FactoryGirl.create(:naive_mooc_provider_user, user: second_user, mooc_provider: mooc_provider, access_token: '123')
        allow(RestClient).to receive(:get).and_return(enrollment_data)
        expect { open_hpi_connector.load_user_data }.not_to raise_error
        expect(user.courses.count).to eql 2
        expect(second_user.courses.count).to eql 2
      end

      it 'does not raise an exception if the saved token is invalid' do
        FactoryGirl.create(:naive_mooc_provider_user, user: user, mooc_provider: mooc_provider, access_token: '123')
        allow(RestClient).to receive(:get).and_raise RestClient::Unauthorized
        expect { open_hpi_connector.load_user_data([user]) }.not_to raise_error
        expect(open_hpi_connector.load_user_data([user])).to eql false
      end

      it 'does not raise an exception if the saved token is invalid even if multiple users should be synchronized' do
        second_user = FactoryGirl.create(:user)
        FactoryGirl.create(:naive_mooc_provider_user, user: user, mooc_provider: mooc_provider, access_token: '123')
        FactoryGirl.create(:naive_mooc_provider_user, user: second_user, mooc_provider: mooc_provider, access_token: '123')
        allow(RestClient).to receive(:get).and_raise RestClient::Unauthorized
        expect { open_hpi_connector.load_user_data }.not_to raise_error
        expect(open_hpi_connector.load_user_data).to eql nil
      end
    end
  end

  context 'synchronize user dates' do
    let(:course) { FactoryGirl.create(:course, mooc_provider: mooc_provider) }

    let(:received_dates) do
      "{
        \"dates\": [
                  {
                    \"course_code\": \"javawork2015\",
                    \"course_id\": \"#{course.provider_course_id}\",
                    \"date\": \"2015-11-30T11:00:00Z\",
                    \"title\": \"I like, I wish: Umfrage zum Kursabschluss\",
                    \"resource_type\": \"item\",
                    \"resource_id\": \"d5ceceda-060e-4797-a08d-53c9bd7f0edd\",
                    \"kind\": \"submission_deadline\"
                  },
                  {
                    \"course_code\": \"ws-privacy2016\",
                    \"course_id\": \"#{course.provider_course_id}\",
                    \"date\": \"2016-01-18T08:00:00Z\",
                    \"title\": \"Social Media - What No One has Told You about Privacy\",
                    \"resource_type\": \"course\",
                    \"resource_id\": \"12500848-0925-4deb-880c-d1b4cff88713\",
                    \"kind\": \"start\"
                  }
                 ]
      }"
    end

    let(:json_user_dates) do
      JSON.parse received_dates
    end

    before(:each) do
      user.courses.push(course)
    end

    describe 'get dates for user' do
      it 'gets an API response' do
        FactoryGirl.create(:naive_mooc_provider_user, user: user, mooc_provider: mooc_provider, access_token: '123')
        expect { open_hpi_connector.send(:get_dates_for_user, user) }.to raise_error RestClient::InternalServerError
      end

      it 'returns parsed response for received dates' do
        FactoryGirl.create(:naive_mooc_provider_user, user: user, mooc_provider: mooc_provider, access_token: '123')
        allow(RestClient).to receive(:get).and_return(received_dates)
        expect(open_hpi_connector.send(:get_dates_for_user, user)).to eql json_user_dates
      end
    end

    describe 'handle dates response' do
      let(:response_data) { json_user_dates }

      it 'calls create_new_entry if there is a date in response data which not yet exists in database' do
        expect(open_hpi_connector).to receive(:create_new_entry).twice
        allow(open_hpi_connector).to receive(:change_existing_no_longer_relevant_entries)
        open_hpi_connector.send(:handle_dates_response, response_data, user)
      end

      it 'calls update_existing_entry if in response data there is user dates which already exists in database' do
        response_data['dates'].each do |user_date|
          FactoryGirl.create(:user_date, user: user, course: course, ressource_id_from_provider: user_date['resource_id'], kind: user_date['kind'])
        end
        expect(open_hpi_connector).to receive(:update_existing_entry).twice
        allow(open_hpi_connector).to receive(:change_existing_no_longer_relevant_entries)
        open_hpi_connector.send(:handle_dates_response, response_data, user)
      end

      it 'calls change_existing_no_longer_relevant_entries' do
        allow(open_hpi_connector).to receive(:create_new_entry)
        expect(open_hpi_connector).to receive(:change_existing_no_longer_relevant_entries).once
        open_hpi_connector.send(:handle_dates_response, response_data, user)
      end
    end

    describe 'create new entry' do
      let(:user_date_data) { json_user_dates['dates'].first }

      it 'creates a new entry in database' do
        expect { open_hpi_connector.send(:create_new_entry, user, user_date_data) }.to change { UserDate.all.count }.by(1)
      end

      it 'sets attribute date to the corresponding value' do
        open_hpi_connector.send(:create_new_entry, user, user_date_data)
        user_date = UserDate.first
        expect(user_date.date).to eq(user_date_data['date'])
      end

      it 'sets attribute title to the corresponding value' do
        open_hpi_connector.send(:create_new_entry, user, user_date_data)
        user_date = UserDate.first
        expect(user_date.title).to eq(user_date_data['title'])
      end

      it 'sets attribute kind to the corresponding value' do
        open_hpi_connector.send(:create_new_entry, user, user_date_data)
        user_date = UserDate.first
        expect(user_date.kind).to eq(user_date_data['kind'])
      end

      it 'sets attribute relevant to the corresponding value' do
        open_hpi_connector.send(:create_new_entry, user, user_date_data)
        user_date = UserDate.first
        expect(user_date.title).to eq(user_date_data['title'])
      end

      it 'sets attribute ressource_id_from_provider to the corresponding value' do
        open_hpi_connector.send(:create_new_entry, user, user_date_data)
        user_date = UserDate.first
        expect(user_date.ressource_id_from_provider).to eq(user_date_data['resource_id'])
      end

      it 'sets attribute user to the corresponding value' do
        open_hpi_connector.send(:create_new_entry, user, user_date_data)
        user_date = UserDate.first
        expect(user_date.user).to eql(user)
      end

      it 'sets attribute course to the corresponding value' do
        open_hpi_connector.send(:create_new_entry, user, user_date_data)
        user_date = UserDate.first
        expect(user_date.course).to eql(course)
      end
    end

    describe 'update existing entry' do
      let(:user_date_data) { json_user_dates['dates'].first }
      let(:user_date) { FactoryGirl.create(:user_date, user: user, course: course, ressource_id_from_provider: user_date_data['resource_id'], kind: user_date_data['kind']) }

      it 'changes attribute date if necessary' do
        user_date.date = user_date_data['date'].to_date + 1.day
        open_hpi_connector.send(:update_existing_entry, user_date, user_date_data)
        expect(user_date.date).to eq(user_date_data['date'])
      end

      it 'changes attribute title if necessary' do
        user_date.date = user_date_data['title'] + 'for testing'
        open_hpi_connector.send(:update_existing_entry, user_date, user_date_data)
        expect(user_date.title).to eq(user_date_data['title'])
      end

      it 'does not create new entry' do
        user_date.date = user_date_data['title'] + 'for testing'
        expect { open_hpi_connector.send(:update_existing_entry, user_date, user_date_data) }.to change { UserDate.count }.by(0)
      end
    end

    describe 'change existing no longer relevant entries' do
      let(:first_user_date) { FactoryGirl.create(:user_date, user: user, course: course) }
      let(:second_user_date) { FactoryGirl.create(:user_date, user: user, course: course) }
      let(:update_map) do
        map = {}
        map.store(first_user_date.id, false)
        map.store(second_user_date.id, true)
        map
      end

      it 'does not change entries which are true in update map' do
        open_hpi_connector.send(:change_existing_no_longer_relevant_entries, update_map)
        expect(UserDate.find(second_user_date.id).relevant).to eql second_user_date.relevant
      end

      it 'changes entries which are false in update map' do
        open_hpi_connector.send(:change_existing_no_longer_relevant_entries, update_map)
        expect(UserDate.find(first_user_date.id).relevant).to eql false
      end
    end
  end
end
