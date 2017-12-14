# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OpenHPIConnector do
  def request_double(url: 'http://example.com', method: 'get')
    instance_double('request', url: url, uri: URI.parse(url), method: method,
                               user: nil, password: nil, cookie_jar: HTTP::CookieJar.new,
                               redirection_history: nil, args: {url: url, method: method})
  end

  let!(:mooc_provider) { FactoryBot.create(:mooc_provider, name: 'openHPI', api_support_state: 'naive') }
  let!(:user) { FactoryBot.create(:user) }
  let(:open_hpi_connector) { described_class.new }

  describe 'mooc_provider' do
    it 'delivers MOOCProvider' do
      expect(open_hpi_connector.send(:mooc_provider)).to eq mooc_provider
    end
  end

  describe 'get access token' do
    it 'returns nil when user has no connection to mooc provider' do
      expect(open_hpi_connector.send(:get_access_token, user)).to eq nil
    end

    it 'returns access_token when user has connection to mooc provider' do
      FactoryBot.create(:naive_mooc_provider_user, user: user, mooc_provider: mooc_provider, access_token: '123')
      expect(open_hpi_connector.send(:get_access_token, user)).to eq '123'
    end
  end

  describe 'connection to mooc provider' do
    it 'returns false when user has no connection to mooc provider' do
      expect(open_hpi_connector.connection_to_mooc_provider?(user)).to eq false
    end

    it 'returns true when user has connection to mooc provider' do
      user.mooc_providers << mooc_provider
      expect(open_hpi_connector.connection_to_mooc_provider?(user)).to eq true
    end
  end

  describe 'initialize connection' do
    let(:credentials) { {email: 'blub@blub.blub', password: 'blubblub'} }

    it 'creates MoocProvider-User connection, when request is answered with token' do
      allow(RestClient).to receive(:post).and_return('{"token":"1234567890"}')
      expect { open_hpi_connector.initialize_connection(user, credentials) }.to change { MoocProviderUser.count }.by(1)
    end

    it 'updates MoocProvider-User connection, when a token is already present and the request is answered with token' do
      FactoryBot.create(:naive_mooc_provider_user, user: user, mooc_provider: mooc_provider, access_token: '123')
      expect(open_hpi_connector.send(:get_access_token, user)).to eq '123'
      allow(RestClient).to receive(:post).and_return('{"token":"1234567890"}')
      expect { open_hpi_connector.initialize_connection(user, credentials) }.to change { MoocProviderUser.count }.by(0)
      expect(open_hpi_connector.send(:get_access_token, user)).to eq '1234567890'
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
      expect(open_hpi_connector.destroy_connection(user)).to eq false
    end
  end

  context 'synchronize user enrollments' do
    let!(:course) { FactoryBot.create(:full_course, provider_course_id: '0c6c5ad1-a770-4f16-81c3-536169f3cbd3', mooc_provider_id: mooc_provider.id) }
    let!(:second_course) { FactoryBot.create(:full_course, provider_course_id: 'bccf2ca2-429c-4cd0-9f63-caaccf85727a', mooc_provider_id: mooc_provider.id) }

    let(:course_enrollment_data) do
      {
        type: 'enrollments',
        id: 'd652d5d6-3624-4fb1-894f-2ea1c05bf5c4',
        links: {
          self: '/api/v2/enrollments/d652d5d6-3624-4fb1-894f-2ea1c05bf5c4'
        },
        attributes: {
          certificates: {
            confirmation_of_participation: "https://open.hpi.de/render_certificate?course_id=#{course.provider_course_id}&type=ConfirmationOfParticipation",
            record_of_achievement: "https://open.hpi.de/render_certificate?course_id=#{course.provider_course_id}&type=RecordOfAchievement",
            qualified_certificate: nil
          },
          completed: false,
          reactivated: false,
          proctored: false,
          created_at: '2016-11-25T17:18:22.627Z'
        },
        relationships: {
          course: {
            data: {
              type: 'courses',
              id: course.provider_course_id
            },
            links: {
              related: "/api/v2/courses/#{course.provider_course_id}"
            }
          },
          progress: {
            data: {
              type: 'course-progresses',
              id: course.provider_course_id
            },
            links: {
              related: "/api/v2/course-progresses/#{course.provider_course_id}"
            }
          }
        }
      }
    end

    let(:single_course_enrollment_data) do
      data = {
        data: course_enrollment_data
      }.to_json
      net_http_res = instance_double('net http response', to_hash: {'Status' => ['200 OK']}, code: 200)
      example_url = 'https://open.hpi.de/api/v2/enrollments'
      request = request_double(url: example_url, method: 'get')
      response = RestClient::Response.create(data, net_http_res, request)
      response
    end

    let(:enrollment_data) do
      data = {
        data: [
          course_enrollment_data,
          {
            type: 'enrollments',
            id: '832b61e8-4dd6-4bdb-a623-ce56262742a7',
            links: {
              self: '/api/v2/enrollments/832b61e8-4dd6-4bdb-a623-ce56262742a7'
            },
            attributes: {
              certificates: {
                confirmation_of_participation: "https://open.hpi.de/render_certificate?course_id=#{second_course.provider_course_id}&type=ConfirmationOfParticipation",
                record_of_achievement: nil,
                qualified_certificate: nil
              },
              completed: true,
              reactivated: false,
              proctored: false,
              created_at: '2016-12-08T12:13:04.205Z'
            },
            relationships: {
              course: {
                data: {
                  type: 'courses',
                  id: second_course.provider_course_id
                },
                links: {
                  related: "/api/v2/courses/#{second_course.provider_course_id}"
                }
              },
              progress: {
                data: {
                  type: 'course-progresses',
                  id: second_course.provider_course_id
                },
                links: {
                  related: "/api/v2/course-progresses/#{second_course.provider_course_id}"
                }
              }
            }
          }
        ]
      }.to_json
      net_http_res = instance_double('net http response', to_hash: {'Status' => ['200 OK']}, code: 200)
      example_url = 'https://open.hpi.de/api/v2/enrollments'
      request = request_double(url: example_url, method: 'get')
      response = RestClient::Response.create(data, net_http_res, request)
      response
    end

    let(:empty_enrollment_data) do
      net_http_res = instance_double('net http response', to_hash: {'Status' => ['200 OK']}, code: 200)
      example_url = 'https://open.hpi.de/api/v2/enrollments'
      request = request_double(url: example_url, method: 'get')
      response = RestClient::Response.create('', net_http_res, request)
      response
    end

    let(:empty_enrollment_data_api_expired) do
      net_http_res = instance_double('net http response', to_hash: {'Status' => ['200 OK'], 'X_Api_Version_Expiration_Date' => ['Tue, 15 Aug 2017 00:00:00 GMT']}, code: 200)
      example_url = 'https://open.hpi.de/api/v2/enrollments'
      request = request_double(url: example_url, method: 'get')
      response = RestClient::Response.create('', net_http_res, request)
      response
    end

    let(:course_progress_data) do
      {
        type: 'course-progresses',
        id: course.provider_course_id,
        attributes: {
          main_exercises: {
            exercises_available: 3,
            exercises_taken: 3,
            points_possible: 48.5,
            points_scored: 48
          },
          selftest_exercises: {
            exercises_available: 2,
            exercises_taken: 0,
            points_possible: 0,
            points_scored: 0
          },
          bonus_exercises: nil,
          visits: {
            items_available: 7,
            items_visited: 5
          }
        },
        relationships: {
          "section-progresses": {
            data: [
              {
                type: 'section-progresses',
                id: '4c546547-4eee-4f4b-b77c-f81f90be0843'
              },
              {
                type: 'section-progresses',
                id: '4fdd88ba-b354-43d0-8dff-8680610549f3'
              },
              {
                type: 'section-progresses',
                id: 'c79c9d48-f326-4856-8d01-ed6ccd691871'
              },
              {
                type: 'section-progresses',
                id: '4194c4f3-0564-4930-81cd-1bcea125672d'
              }
            ]
          }
        }
      }
    end

    let(:single_course_progress_data) do
      data = {
        data: course_progress_data
      }.to_json
      net_http_res = instance_double('net http response', to_hash: {'Status' => ['200 OK']}, code: 200)
      example_url = "https://open.hpi.de/api/v2/course-progresses/#{course.provider_course_id}"
      request = request_double(url: example_url, method: 'get')
      response = RestClient::Response.create(data, net_http_res, request)
      response
    end

    let(:json_enrollment_data) do
      JSON::Api::Vanilla.parse enrollment_data
    end

    describe 'get enrollments for user' do
      it 'gets an API response' do
        FactoryBot.create(:naive_mooc_provider_user, user: user, mooc_provider: mooc_provider, access_token: '123')
        expect { open_hpi_connector.send(:get_enrollments_for_user, user) }.to raise_error RestClient::InternalServerError
      end

      it 'returns parsed response for enrolled courses' do
        FactoryBot.create(:naive_mooc_provider_user, user: user, mooc_provider: mooc_provider, access_token: '123')
        allow(RestClient).to receive(:get).and_return(enrollment_data)
        allow(JSON::Api::Vanilla).to receive(:parse).with(enrollment_data.to_s).and_return(json_enrollment_data)
        expect(open_hpi_connector.send(:get_enrollments_for_user, user)).to eq json_enrollment_data
      end
    end

    describe 'handle enrollments response' do
      it 'loads new enrollment into database' do
        allow(RestClient).to receive(:get).and_raise RestClient::InternalServerError # for the course progress
        expect do
          open_hpi_connector.send(:handle_enrollments_response, json_enrollment_data, user)
        end.to change(user.courses, :count).by(2)
      end

      it 'adds course enrollment into database' do
        UserCourse.create!(user: user, course: second_course, provider_id: '832b61e8-4dd6-4bdb-a623-ce56262742a7')
        allow(RestClient).to receive(:get).and_raise RestClient::InternalServerError # for the course progress
        open_hpi_connector.send(:handle_enrollments_response, json_enrollment_data, user)

        course_id = File.basename(json_enrollment_data.rel_links.values.first['related'])
        enrolled_course = Course.get_course_by_mooc_provider_id_and_provider_course_id mooc_provider.id, course_id
        enrollment = UserCourse.find_by(course: enrolled_course, user: user)
        expect(enrollment).not_to be_nil
        expect(enrollment.provider_id).to eq 'd652d5d6-3624-4fb1-894f-2ea1c05bf5c4'
        expect(user.courses).to contain_exactly(course, second_course)
      end

      it 'loads completion data into database' do
        allow(RestClient).to receive(:get).and_raise RestClient::InternalServerError # for the course progress
        expect do
          open_hpi_connector.send(:handle_enrollments_response, json_enrollment_data, user)
        end.to change(user.completions, :count).by(1)
      end

      it 'adds course completion data' do
        allow(RestClient).to receive(:get).and_return single_course_progress_data
        open_hpi_connector.send(:handle_enrollments_response, json_enrollment_data, user)
        completion = Completion.find_by(user: user)

        second_course.reload

        expect(completion.quantile).to be_nil
        expect(completion.points_achieved).to eq 48
        expect(completion.course.points_maximal).to eq 48.5
        expect(completion.course).to eq second_course
        expect(completion.provider_percentage).to eq 98.9690721649485
      end

      it 'adds certificates after completing the course' do
        allow(RestClient).to receive(:get).and_return single_course_progress_data
        open_hpi_connector.send(:handle_enrollments_response, json_enrollment_data, user)
        completion = Completion.find_by(user: user)
        expect(completion.certificates.count).to be 1
        expect(completion.certificates.first.download_url).to eq "https://open.hpi.de/render_certificate?course_id=#{second_course.provider_course_id}&type=ConfirmationOfParticipation"
        expect(completion.certificates.first.document_type).to eq 'confirmation_of_participation'
      end

      it 'works with empty responses' do
        FactoryBot.create(:naive_mooc_provider_user, user: user, mooc_provider: mooc_provider, access_token: '123')
        allow_any_instance_of(described_class).to receive(:get_enrollments_for_user).and_return([])
        expect { open_hpi_connector.load_dates_for_users([user]) }.not_to raise_exception
      end

      context 'email notification' do
        before do
          ActionMailer::Base.deliveries.clear
          Settings.admin_email_address = 'admin@example.com'
        end

        it 'is sent to the administrator if api expiration header is present' do
          allow(RestClient).to receive(:get).and_return(empty_enrollment_data_api_expired)
          expect { open_hpi_connector.send(:get_enrollments_for_user, user) }.not_to raise_error
          expect(ActionMailer::Base.deliveries.count).to eq 1
        end

        it 'is sent to the administrator if api expiration header is not present' do
          allow(RestClient).to receive(:get).and_return(empty_enrollment_data)
          expect { open_hpi_connector.send(:get_enrollments_for_user, user) }.not_to raise_error
          expect(ActionMailer::Base.deliveries.count).to eq 0
        end
      end
    end

    describe 'enroll user for course' do
      it 'returns nil when trying to enroll and user has no mooc provider connection' do
        expect(open_hpi_connector.enroll_user_for_course(user, course)).to eq nil
      end

      it 'returns false when trying to enroll and user has mooc provider connection but something went wrong' do
        user.mooc_providers << mooc_provider
        allow(RestClient).to receive(:post).and_raise RestClient::Unauthorized
        expect(open_hpi_connector.enroll_user_for_course(user, course)).to eq false
      end

      it 'returns true when trying to enroll and everything was ok' do
        user.mooc_providers << mooc_provider
        allow(RestClient).to receive(:post).and_return(single_course_enrollment_data)
        expect(open_hpi_connector.enroll_user_for_course(user, course)).to eq true
      end

      it 'handles internal server error for course enrollments' do
        user.mooc_providers << mooc_provider
        allow(open_hpi_connector).to receive(:send_enrollment_for_course).and_raise RestClient::InternalServerError
        expect { open_hpi_connector.enroll_user_for_course(user, course) }.not_to raise_error
      end
    end

    describe 'unenroll user for course' do
      it 'returns nil when trying to unenroll and user has no mooc provider connection' do
        expect(open_hpi_connector.unenroll_user_for_course(user, course)).to eq nil
      end

      it 'returns false when trying to unenroll and user has mooc provider connection but something went wrong' do
        user.mooc_providers << mooc_provider
        UserCourse.create!(user: user, course: course, provider_id: 'd652d5d6-3624-4fb1-894f-2ea1c05bf5c4')
        allow(RestClient).to receive(:delete).and_raise RestClient::Unauthorized
        expect(open_hpi_connector.unenroll_user_for_course(user, course)).to eq false
      end

      it 'returns true when trying to unenroll and everything was ok' do
        user.mooc_providers << mooc_provider
        UserCourse.create!(user: user, course: course, provider_id: 'd652d5d6-3624-4fb1-894f-2ea1c05bf5c4')
        allow(RestClient).to receive(:delete).and_return(empty_enrollment_data)
        expect(open_hpi_connector.unenroll_user_for_course(user, course)).to eq true
      end

      it 'handles internal server error for course unenrollments' do
        user.mooc_providers << mooc_provider
        allow(open_hpi_connector).to receive(:send_unenrollment_for_course).and_raise RestClient::InternalServerError
        expect { open_hpi_connector.unenroll_user_for_course(user, course) }.not_to raise_error
      end

      context 'email notification' do
        before do
          ActionMailer::Base.deliveries.clear
          Settings.admin_email_address = 'admin@example.com'
        end

        it 'is sent to the administrator if api expiration header is present' do
          allow(RestClient).to receive(:delete).and_return(empty_enrollment_data_api_expired)
          UserCourse.create!(user: user, course: course, provider_id: 'd652d5d6-3624-4fb1-894f-2ea1c05bf5c4')
          expect { open_hpi_connector.send(:send_unenrollment_for_course, user, course) }.not_to raise_error
          expect(ActionMailer::Base.deliveries.count).to eq 1
        end

        it 'is sent to the administrator if api expiration header is not present' do
          allow(RestClient).to receive(:delete).and_return(empty_enrollment_data)
          expect { open_hpi_connector.send(:send_unenrollment_for_course, user, course) }.not_to raise_error
          expect(ActionMailer::Base.deliveries.count).to eq 0
        end
      end
    end

    describe 'load user data' do
      it 'loads specified user data for a given user' do
        FactoryBot.create(:naive_mooc_provider_user, user: user, mooc_provider: mooc_provider, access_token: '123')
        allow(RestClient).to receive(:get).and_return(enrollment_data, single_course_progress_data)
        expect { open_hpi_connector.load_user_data([user]) }.not_to raise_error
        expect(user.courses.count).to eq 2
      end

      it 'loads specified user data for all users' do
        second_user = FactoryBot.create(:user)
        FactoryBot.create(:naive_mooc_provider_user, user: user, mooc_provider: mooc_provider, access_token: '123')
        FactoryBot.create(:naive_mooc_provider_user, user: second_user, mooc_provider: mooc_provider, access_token: '123')
        allow(RestClient).to receive(:get).and_return(enrollment_data, single_course_progress_data, single_course_progress_data, enrollment_data, single_course_progress_data)
        expect { open_hpi_connector.load_user_data }.not_to raise_error
        expect(user.courses.count).to eq 2
        expect(second_user.courses.count).to eq 2
      end

      it 'does not raise an exception if the saved token is invalid' do
        FactoryBot.create(:naive_mooc_provider_user, user: user, mooc_provider: mooc_provider, access_token: '123')
        allow(RestClient).to receive(:get).and_raise RestClient::Unauthorized
        expect { open_hpi_connector.load_user_data([user]) }.not_to raise_error
        expect(open_hpi_connector.load_user_data([user])).to eq false
      end

      it 'does not raise an exception if the saved token is invalid even if multiple users should be synchronized' do
        second_user = FactoryBot.create(:user)
        FactoryBot.create(:naive_mooc_provider_user, user: user, mooc_provider: mooc_provider, access_token: '123')
        FactoryBot.create(:naive_mooc_provider_user, user: second_user, mooc_provider: mooc_provider, access_token: '123')
        allow(RestClient).to receive(:get).and_raise RestClient::Unauthorized
        expect { open_hpi_connector.load_user_data }.not_to raise_error
        expect(open_hpi_connector.load_user_data).to eq nil
      end
    end
  end

  context 'synchronize user dates' do
    let(:course) { FactoryBot.create(:course, mooc_provider: mooc_provider) }

    let(:received_dates) do
      data = "{
    \"data\": [
        {
            \"type\": \"course-dates\",
            \"id\": \"ebdee8e82476e378ff0e0164feca7653\",
            \"attributes\": {
                \"type\": \"course_start\",
                \"title\": \"Java Workshop - Einführung in die Testgetriebene Entwicklung mit JUnit\",
                \"date\": \"2016-05-02T08:00:00.000+00:00\"
            },
            \"relationships\": {
                \"course\": {
                    \"data\": {
                        \"type\": \"courses\",
                        \"id\": \"#{course.provider_course_id}\"
                    },
                    \"links\": {
                        \"related\": \"/api/v2/courses/#{course.provider_course_id}\"
                    }
                }
            }
        },
        {
            \"type\": \"course-dates\",
            \"id\": \"666f52643ae77da0e4f5272d4a81c8e3\",
            \"links\": {
                \"item_html\": \"/courses/imdb2017/items/aXrcT1PNh7L2d6erwly6b\"
            },
            \"attributes\": {
                \"type\": \"item_submission_deadline\",
                \"title\": \"Week 4: Assignment Embedded Smart Home\",
                \"date\": \"2016-06-06T08:00:00.000+00:00\"
            },
            \"relationships\": {
                \"course\": {
                    \"data\": {
                        \"type\": \"courses\",
                        \"id\": \"#{course.provider_course_id}\"
                    },
                    \"links\": {
                        \"related\": \"/api/v2/courses/#{course.provider_course_id}\"
                    }
                }
            }
        }
    ]
}"
      net_http_res = instance_double('net http response', to_hash: {'Status' => ['200 OK']}, code: 200)
      example_url = 'https://open.hpi.de/api/v2/course-dates'
      request = request_double(url: example_url, method: 'get')
      response = RestClient::Response.create(data, net_http_res, request)
      response
    end

    let(:empty_received_dates_api_expired) do
      net_http_res = instance_double('net http response', to_hash: {'Status' => ['200 OK'], 'X_Api_Version_Expiration_Date' => ['Tue, 15 Aug 2017 00:00:00 GMT']}, code: 200)
      example_url = 'https://open.hpi.de/api/v2/course-dates'
      request = request_double(url: example_url, method: 'get')
      response = RestClient::Response.create('', net_http_res, request)
      response
    end

    let(:json_user_dates) do
      JSON::Api::Vanilla.parse received_dates
    end

    before do
      user.courses.push(course)
    end

    describe 'get dates for user' do
      it 'gets an API response' do
        FactoryBot.create(:naive_mooc_provider_user, user: user, mooc_provider: mooc_provider)
        expect { open_hpi_connector.send(:get_dates_for_user, user) }.to raise_error RestClient::Unauthorized
      end

      it 'returns parsed response for received dates' do
        FactoryBot.create(:naive_mooc_provider_user, user: user, mooc_provider: mooc_provider, access_token: 'Legacy-Token token=123')
        allow(RestClient).to receive(:get).and_return(received_dates)
        allow(JSON::Api::Vanilla).to receive(:parse).with(received_dates.to_s).and_return(json_user_dates)
        expect(open_hpi_connector.send(:get_dates_for_user, user)).to eq json_user_dates
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
        response_data.keys.each do |date| # rubocop:disable Performance/HashEachMethods
          external_date_id = date.first.id
          user_date = date.last
          FactoryBot.create(:user_date, user: user, course: course, ressource_id_from_provider: external_date_id, kind: user_date['type'])
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
      let(:user_date_data) { json_user_dates.keys.first.last }
      let(:user_date_course) { File.basename(json_user_dates.rel_links.values.first['related']) }
      let(:user_date_external_id) { json_user_dates.keys.first.first.id }

      it 'creates a new entry in database' do
        expect { open_hpi_connector.send(:create_new_entry, user, user_date_data, user_date_course, user_date_external_id) }.to change { UserDate.all.count }.by(1)
      end

      it 'sets attribute date to the corresponding value' do
        open_hpi_connector.send(:create_new_entry, user, user_date_data, user_date_course, user_date_external_id)
        user_date = UserDate.first
        expect(user_date.date).to eq(user_date_data['date'])
      end

      it 'sets attribute title to the corresponding value' do
        open_hpi_connector.send(:create_new_entry, user, user_date_data, user_date_course, user_date_external_id)
        user_date = UserDate.first
        expect(user_date.title).to eq(user_date_data['title'])
      end

      it 'sets attribute kind to the corresponding value' do
        open_hpi_connector.send(:create_new_entry, user, user_date_data, user_date_course, user_date_external_id)
        user_date = UserDate.first
        expect(user_date.kind).to eq(user_date_data['type'])
      end

      it 'sets attribute relevant to the corresponding value' do
        open_hpi_connector.send(:create_new_entry, user, user_date_data, user_date_course, user_date_external_id)
        user_date = UserDate.first
        expect(user_date.relevant).to be true
      end

      it 'sets attribute ressource_id_from_provider to the corresponding value' do
        open_hpi_connector.send(:create_new_entry, user, user_date_data, user_date_course, user_date_external_id)
        user_date = UserDate.first
        expect(user_date.ressource_id_from_provider).to eq(user_date_external_id)
      end

      it 'sets attribute user to the corresponding value' do
        open_hpi_connector.send(:create_new_entry, user, user_date_data, user_date_course, user_date_external_id)
        user_date = UserDate.first
        expect(user_date.user).to eq(user)
      end

      it 'sets attribute course to the corresponding value' do
        open_hpi_connector.send(:create_new_entry, user, user_date_data, user_date_course, user_date_external_id)
        user_date = UserDate.first
        expect(user_date.course).to eq(course)
      end
    end

    describe 'update existing entry' do
      let(:user_date_data) { json_user_dates.keys.first.last }
      let(:user_date_course) { File.basename(json_user_dates.rel_links.values.first['related']) }
      let(:user_date_external_id) { json_user_dates.keys.first.first.id }
      let(:user_date) { FactoryBot.create(:user_date, user: user, course: course, ressource_id_from_provider: user_date_external_id, kind: user_date_data['type']) }

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
      let(:first_user_date) { FactoryBot.create(:user_date, user: user, course: course) }
      let(:second_user_date) { FactoryBot.create(:user_date, user: user, course: course) }
      let(:update_map) do
        map = {}
        map.store(first_user_date.id, false)
        map.store(second_user_date.id, true)
        map
      end

      it 'does not change entries which are true in update map' do
        open_hpi_connector.send(:change_existing_no_longer_relevant_entries, update_map)
        expect(UserDate.find(second_user_date.id).relevant).to eq second_user_date.relevant
      end

      it 'changes entries which are false in update map' do
        open_hpi_connector.send(:change_existing_no_longer_relevant_entries, update_map)
        expect(UserDate.find(first_user_date.id).relevant).to eq false
      end
    end

    it 'works with empty responses' do
      FactoryBot.create(:naive_mooc_provider_user, user: user, mooc_provider: mooc_provider, access_token: '123')
      allow_any_instance_of(described_class).to receive(:get_dates_for_user).and_return([])
      expect { open_hpi_connector.load_dates_for_users([user]) }.not_to raise_exception
    end

    context 'email notification' do
      before do
        ActionMailer::Base.deliveries.clear
        Settings.admin_email_address = 'admin@example.com'
      end

      it 'is sent to the administrator if api expiration header is present' do
        allow(RestClient).to receive(:get).and_return(empty_received_dates_api_expired)
        expect { open_hpi_connector.send(:get_dates_for_user, user) }.not_to raise_error
        expect(ActionMailer::Base.deliveries.count).to eq 1
      end

      it 'is sent to the administrator if api expiration header is not present' do
        allow(RestClient).to receive(:get).and_return(received_dates)
        expect { open_hpi_connector.send(:get_dates_for_user, user) }.not_to raise_error
        expect(ActionMailer::Base.deliveries.count).to eq 0
      end
    end
  end
end
