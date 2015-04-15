require 'rails_helper'

describe OpenHPICourseWorker do

  let!(:mooc_provider) { FactoryGirl.create(:mooc_provider, name: 'openHPI') }
  let!(:course) { FactoryGirl.create(:full_course, provider_course_id: '0c6c5ad1-a770-4f16-81c3-536169f3cbd3', mooc_provider_id: mooc_provider.id) }
  let!(:user) { FactoryGirl.create(:user) }

  let(:open_hpi_user_worker){
    OpenHPIUserWorker.new
  }

  let(:json_enrollment_data) {
    JSON.parse '[{"id":"dfcfdf0f-e0ad-4887-abfa-83cc233c291f","course_id":"c5600abf-5abf-460b-ba6f-1d030053fd79"},{"id":"bbc4c2a7-51ed-460a-a312-6ba4b3da3545","course_id":"0c6c5ad1-a770-4f16-81c3-536169f3cbd3"},{"id":"48edd6a8-3a9a-4a64-8b5c-631142022d15","course_id":"bccf2ca2-429c-4cd0-9f63-caaccf85727a"}]'
  }

  it 'should deliver MOOCProvider' do
    expect(open_hpi_user_worker.mooc_provider).to eql mooc_provider
  end

  it 'should get an API response' do
    connection = MoocProviderUser.new
    connection.authentication_token = '1234567890abcdef'
    connection.user_id = user.id
    connection.mooc_provider_id = mooc_provider.id
    connection.save
    expect{open_hpi_user_worker.get_enrollments_for_user user}.to raise_error RestClient::InternalServerError
  end

  it 'should load new enrollment into database' do
    expect{
      open_hpi_user_worker.handle_enrollments_response json_enrollment_data, user
    }.to change(user.courses, :count).by(1)
  end

  it 'should load course enrollment into database' do
    open_hpi_user_worker.handle_enrollments_response json_enrollment_data, user

    json_enrollment = json_enrollment_data[1]
    course_id = Course.get_course_id_by_mooc_provider_id_and_provider_course_id mooc_provider.id, json_enrollment['course_id']
    enrollment_array = user.courses.where(:id => course_id)
    expect(enrollment_array).not_to be_empty
  end
end
