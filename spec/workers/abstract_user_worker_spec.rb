require 'rails_helper'
require 'sidekiq/testing'

describe AbstractUserWorker do

  before(:all) do
    @mooc_provider = FactoryGirl.create(:mooc_provider)
    @user = FactoryGirl.create(:user)
    @course = FactoryGirl.create(:full_course, mooc_provider_id: @mooc_provider.id)
    @second_course = FactoryGirl.create(:full_course, mooc_provider_id: @mooc_provider.id)
    @user.courses << @course
    @user.courses << @second_course
  end

  let (:abstract_user_worker) {
    AbstractUserWorker.new
  }

  it 'should create a valid update_map' do
    update_map = abstract_user_worker.create_enrollments_update_map @mooc_provider, @user
    expect(update_map.length).to eql 2
    update_map.each { |_, updated|
      expect(updated).to be false
    }
  end

  it 'should evaluate the update_map and delete the right enrollment' do
    expect{
      update_map = abstract_user_worker.create_enrollments_update_map @mooc_provider, @user

      # set one enrollment to true -> prevent from deleting
      update_map.each_with_index { |(enrollment, _), index |
        update_map[enrollment] = true
        index >= 0 ? break : next
      }

      abstract_user_worker.evaluate_enrollments_update_map update_map, @user
    }.to change(@user.courses, :count).by(-1)
  end

  it 'should throw exceptions when trying to call abstract methods' do
    expect{abstract_user_worker.mooc_provider}.to raise_error NotImplementedError
    expect{abstract_user_worker.get_enrollments_for_user @user}.to raise_error NotImplementedError
    expect{abstract_user_worker.handle_enrollments_response 'test', @user}.to raise_error NotImplementedError
  end

  it 'should handle internet connection error' do
    allow(abstract_user_worker).to receive(:get_enrollments_for_user).and_raise SocketError
    expect{abstract_user_worker.load_user_data @user}.not_to raise_error
  end

  it 'should handle API not found error' do
    allow(abstract_user_worker).to receive(:get_enrollments_for_user).and_raise RestClient::ResourceNotFound
    expect{abstract_user_worker.load_user_data @user}.not_to raise_error
  end

end
