require 'rails_helper'

RSpec.describe OpenHPIConnector do

  let!(:mooc_provider) { FactoryGirl.create(:mooc_provider, name: 'openHPI') }
  let!(:course) { FactoryGirl.create(:full_course, provider_course_id: '0c6c5ad1-a770-4f16-81c3-536169f3cbd3', mooc_provider_id: mooc_provider.id) }
  let!(:second_course) { FactoryGirl.create(:full_course, provider_course_id: 'bccf2ca2-429c-4cd0-9f63-caaccf85727a', mooc_provider_id: mooc_provider.id) }
  let!(:user) { FactoryGirl.create(:user) }
  let(:credentials) {{email: 'blub@blub.blub', password: 'blubblub'}}

  let(:open_hpi_connector){ OpenHPIConnector.new }

  let(:json_enrollment_data) {
    JSON.parse '[{"id":"dfcfdf0f-e0ad-4887-abfa-83cc233c291f","course_id":"c5600abf-5abf-460b-ba6f-1d030053fd79"},{"id":"bbc4c2a7-51ed-460a-a312-6ba4b3da3545","course_id":"0c6c5ad1-a770-4f16-81c3-536169f3cbd3"},{"id":"48edd6a8-3a9a-4a64-8b5c-631142022d15","course_id":"bccf2ca2-429c-4cd0-9f63-caaccf85727a"}]'
  }

  let(:enrollment_data) {
    '[{"id":"dfcfdf0f-e0ad-4887-abfa-83cc233c291f","course_id":"c5600abf-5abf-460b-ba6f-1d030053fd79"},{"id":"bbc4c2a7-51ed-460a-a312-6ba4b3da3545","course_id":"0c6c5ad1-a770-4f16-81c3-536169f3cbd3"},{"id":"48edd6a8-3a9a-4a64-8b5c-631142022d15","course_id":"bccf2ca2-429c-4cd0-9f63-caaccf85727a"}]'
  }

  it 'should deliver MOOCProvider' do
    expect(open_hpi_connector.send(:mooc_provider)).to eql mooc_provider
  end

  it 'should get an API response' do
    FactoryGirl.create(:mooc_provider_user, user: user, mooc_provider: mooc_provider, authentication_token: '123')
    expect{open_hpi_connector.send(:get_enrollments_for_user, user)}.to raise_error RestClient::InternalServerError
  end

  it 'should return parsed response for enrolled courses' do
    FactoryGirl.create(:mooc_provider_user, user: user, mooc_provider: mooc_provider, authentication_token: '123')
    allow(RestClient).to receive(:get).and_return(enrollment_data)
    expect(open_hpi_connector.send(:get_enrollments_for_user, user)).to eql json_enrollment_data
  end

  it 'should load new enrollment into database' do
    expect{
      open_hpi_connector.send(:handle_enrollments_response, json_enrollment_data, user)
    }.to change(user.courses, :count).by(2)
  end

  it 'should add course enrollment into database' do
    user.courses << second_course
    open_hpi_connector.send(:handle_enrollments_response, json_enrollment_data, user)

    json_enrollment = json_enrollment_data[1]
    course_id = Course.get_course_id_by_mooc_provider_id_and_provider_course_id mooc_provider.id, json_enrollment['course_id']
    enrollment_array = user.courses.where(id: course_id)
    expect(enrollment_array).not_to be_empty
    expect(user.courses).to contain_exactly(course, second_course)
  end

  it 'should return nil when trying to enroll and user has no mooc provider connection' do
    expect(open_hpi_connector.enroll_user_for_course user, course).to eql nil
  end

  it 'should return false when trying to enroll and user has mooc provider connection but something went wrong' do
    user.mooc_providers << mooc_provider
    expect(open_hpi_connector.enroll_user_for_course user, course).to eql false
  end

  it 'should return true when trying to enroll and everything was ok' do
    user.mooc_providers << mooc_provider
    allow(RestClient).to receive(:post).and_return('{"success"}')
    expect(open_hpi_connector.enroll_user_for_course user, course).to eql true
  end

  it 'should return nil when trying to unenroll and user has no mooc provider connection' do
    expect(open_hpi_connector.unenroll_user_for_course user, course).to eql nil
  end

  it 'should return false when trying to unenroll and user has mooc provider connection but something went wrong' do
    user.mooc_providers << mooc_provider
    expect(open_hpi_connector.unenroll_user_for_course user, course).to eql false
  end

  it 'should return true when trying to unenroll and everything was ok' do
    user.mooc_providers << mooc_provider
    allow(RestClient).to receive(:delete).and_return('{"success"}')
    expect(open_hpi_connector.unenroll_user_for_course user, course).to eql true
  end

  it 'should return nil when user has no connection to mooc provider' do
    expect(open_hpi_connector.send(:get_authentication_token, user)).to eql nil
  end

  it 'should return authentication_token when user has connection to mooc provider' do
    FactoryGirl.create(:mooc_provider_user, user: user, mooc_provider: mooc_provider, authentication_token: '123')
    expect(open_hpi_connector.send(:get_authentication_token, user)).to eql '123'
  end

  it 'should return false when user has no conncetion to mooc provider' do
    expect(open_hpi_connector.has_connection_to_mooc_provider user).to eql false
  end

  it 'should return true when user has conncetion to mooc provider' do
    user.mooc_providers << mooc_provider
    expect(open_hpi_connector.has_connection_to_mooc_provider user).to eql true
  end

  it 'should create MoocProvider-User connection, when request is answered with token' do
    allow(RestClient).to receive(:post).and_return('{"token":"1234567890"}')
    expect{open_hpi_connector.initialize_connection(user, credentials)}.to change{MoocProviderUser.count}.by(1)
  end

  it 'should not create MoocProvider-User connection, when request is answered with empty token' do
    allow(RestClient).to receive(:post).and_return('{"token":""}')
    expect{open_hpi_connector.initialize_connection(user, credentials)}.to change{MoocProviderUser.count}.by(0)
  end

  it 'should handle internal server error for course enrollments' do
    user.mooc_providers << mooc_provider
    allow(open_hpi_connector).to receive(:send_enrollment_for_course).and_raise RestClient::InternalServerError
    expect{open_hpi_connector.enroll_user_for_course(user, course)}.not_to raise_error
  end

  it 'should handle internal server error for course unenrollments' do
    user.mooc_providers << mooc_provider
    allow(open_hpi_connector).to receive(:send_unenrollment_for_course).and_raise RestClient::InternalServerError
    expect{open_hpi_connector.unenroll_user_for_course(user, course)}.not_to raise_error
  end

  it 'should handle internal server error for token request' do
    user.mooc_providers << mooc_provider
    allow(open_hpi_connector).to receive(:send_connection_request).and_raise RestClient::InternalServerError
    expect{open_hpi_connector.initialize_connection(user, credentials)}.not_to raise_error
  end

  it 'should load specified user data for a given user' do
    FactoryGirl.create(:mooc_provider_user, user: user, mooc_provider: mooc_provider, authentication_token: '123')
    allow(RestClient).to receive(:get).and_return(enrollment_data)
    expect{open_hpi_connector.load_user_data([user])}.not_to raise_error
    expect(user.courses.count).to eql 2
  end

  it 'should load specified user data for all users' do
    second_user = FactoryGirl.create(:user)
    FactoryGirl.create(:mooc_provider_user, user: user, mooc_provider: mooc_provider, authentication_token: '123')
    FactoryGirl.create(:mooc_provider_user, user: second_user, mooc_provider: mooc_provider, authentication_token: '123')
    allow(RestClient).to receive(:get).and_return(enrollment_data)
    expect{open_hpi_connector.load_user_data()}.not_to raise_error
    expect(user.courses.count).to eql 2
    expect(second_user.courses.count).to eql 2
  end
end
