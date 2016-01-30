# -*- encoding : utf-8 -*-
require 'rails_helper'

RSpec.describe CourseraConnector do
  let!(:mooc_provider) { FactoryGirl.create(:mooc_provider, name: 'coursera', api_support_state: 'oauth') }
  let!(:course) { FactoryGirl.create(:full_course, provider_course_id: '1354|972508', mooc_provider_id: mooc_provider.id) }
  let!(:second_course) { FactoryGirl.create(:full_course, provider_course_id: '9|974782', mooc_provider_id: mooc_provider.id) }
  let!(:user) { FactoryGirl.create(:user) }
  let(:credentials) { {code: 'code_passed_to_callback_url'} }

  let(:coursera_connector) { described_class.new }

  let(:enrollment_data) do
    '{"enrollments":[{"id":112825720,"sessionId":972508,"isSigTrack":false,"courseId":1354,"active":false,"startDate":1433116800,"endDate":1439164800,"startStatus":"Future"},{"id":112825821,"sessionId":974782,"isSigTrack":false,"courseId":9,"active":true,"startDate":1429488000,"endDate":1433116800,"startStatus":"Present"}],"courses":[{"id":9,"name":"Cryptography I","shortName":"crypto","photo":"https://s3.amazonaws.com/coursera/topics/crypto/large-icon.png","smallIconHover":"https://d1z850dzhxs7de.cloudfront.net/topics/crypto/small-icon.hover.png"},{"id":1354,"name":"Programming for Everybody (Python)","shortName":"pythonlearn","photo":"https://coursera-course-photos.s3.amazonaws.com/c3/ddf0307fbf11e3aab111bf138e57ac/MOOCMap-highres.jpg","smallIconHover":"https://d15cw65ipctsrr.cloudfront.net/c4/e686907fbf11e3bfb3290ba1eec481/MOOCMap-highres.jpg"}]}'
  end

  let(:json_enrollment_data) do
    JSON.parse enrollment_data
  end

  it 'delivers MOOCProvider' do
    expect(coursera_connector.send(:mooc_provider)).to eql mooc_provider
  end

  it 'gets an API response' do
    FactoryGirl.create(:oauth_mooc_provider_user, user: user, mooc_provider: mooc_provider, access_token: '123')
    expect { coursera_connector.send(:get_enrollments_for_user, user) }.to raise_error RestClient::Unauthorized
  end

  it 'returns parsed response for enrolled courses' do
    FactoryGirl.create(:oauth_mooc_provider_user, user: user, mooc_provider: mooc_provider, access_token: '123')
    allow(RestClient).to receive(:get).and_return(enrollment_data)
    expect(coursera_connector.send(:get_enrollments_for_user, user)).to eql json_enrollment_data
  end

  it 'loads new enrollment into database' do
    expect do
      coursera_connector.send(:handle_enrollments_response, json_enrollment_data, user)
    end.to change(user.courses, :count).by(2)
  end

  it 'adds course enrollment into database' do
    user.courses << second_course
    coursera_connector.send(:handle_enrollments_response, json_enrollment_data, user)

    json_enrollment = json_enrollment_data['enrollments'][0]
    enrolled_course = Course.get_course_by_mooc_provider_id_and_provider_course_id(mooc_provider.id, "#{json_enrollment['courseId']}|#{json_enrollment['sessionId']}")
    enrollment_array = user.courses.where(id: enrolled_course.id)
    expect(enrollment_array).not_to be_empty
    expect(user.courses).to contain_exactly(course, second_course)
  end

  it 'throws a NotImplementedError when trying to enroll even if user has a connection to the MOOC provider' do
    FactoryGirl.create(:oauth_mooc_provider_user, user: user, mooc_provider: mooc_provider, access_token: '123')
    expect { coursera_connector.enroll_user_for_course user, course }.to raise_error NotImplementedError
  end

  it 'throws a NotImplementedError when trying to unenroll even if user has a connection to the MOOC provider' do
    FactoryGirl.create(:oauth_mooc_provider_user, user: user, mooc_provider: mooc_provider, access_token: '123')
    expect { coursera_connector.unenroll_user_for_course user, course }.to raise_error NotImplementedError
  end

  it 'returns nil when user has no connection to mooc provider' do
    expect(coursera_connector.send(:get_access_token, user)).to eql nil
  end

  it 'returns access_token when user has connection to mooc provider, which is still valid' do
    FactoryGirl.create(:oauth_mooc_provider_user, user: user, mooc_provider: mooc_provider, access_token: '123')
    expect(coursera_connector.send(:get_access_token, user)).to eql '123'
  end

  it 'returns nil when user has connection to mooc provider, which is no longer valid' do
    FactoryGirl.create(:oauth_mooc_provider_user, user: user, mooc_provider: mooc_provider, access_token: '123', access_token_valid_until: Time.zone.now - 5.minutes)
    expect(coursera_connector.send(:get_access_token, user)).to eql nil
  end

  it 'does not try to refresh the access_token when no refresh_token is given' do
    FactoryGirl.create(:oauth_mooc_provider_user, user: user, mooc_provider: mooc_provider, access_token: '123', access_token_valid_until: Time.zone.now - 5.minutes)
    expect_any_instance_of(described_class).not_to receive(:refresh_access_token)
    coursera_connector.send(:get_access_token, user)
  end

  it 'returns false when user has no connection to mooc provider' do
    expect(coursera_connector.connection_to_mooc_provider? user).to eql false
  end

  it 'returns true when user has connection to mooc provider' do
    user.mooc_providers << mooc_provider
    expect(coursera_connector.connection_to_mooc_provider? user).to eql true
  end

  it 'returns a new instance of the OAuth2 Client' do
    expect(coursera_connector.send(:oauth_client).class).to eql OAuth2::Client
  end

  it 'returns a valid link if required' do
    client_id = 'abc'
    stub_const('CourseraConnector::OAUTH_CLIENT_ID', client_id)
    stub_const('CourseraConnector::OAUTH_SECRET_KEY', '5€cr€t')
    redirect_uri = CGI.escape(CourseraConnector::REDIRECT_URI)
    oauth_client = coursera_connector.send(:oauth_client)
    destination = '/own/path'
    destination_path = CGI.escape(destination)
    csrf_token = CGI.escape('my_csrf_token')
    expected_url = "#{oauth_client.site}#{oauth_client.authorize_url}?client_id=#{client_id}&redirect_uri=#{redirect_uri}&response_type=code&scope=view_profile&state=coursera~#{destination_path}~#{csrf_token}"
    expect(coursera_connector.oauth_link(destination, csrf_token)).to eql expected_url
  end

  it 'saves the access_token' do
    oauth_client = coursera_connector.send(:oauth_client)
    access_token = OAuth2::AccessToken.new(oauth_client, '0123456789abcdef', expires_in: 1800.seconds)
    allow_any_instance_of(OAuth2::Strategy::AuthCode).to receive(:get_token).and_return(access_token)
    expect { coursera_connector.initialize_connection(user, credentials) }.to change(user.mooc_providers, :count).by(1)
    expect(coursera_connector.send(:get_access_token, user)).to eql access_token.token
  end
end
