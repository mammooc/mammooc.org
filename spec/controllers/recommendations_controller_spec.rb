require 'rails_helper'

RSpec.describe RecommendationsController, :type => :controller do

  let(:user) {FactoryGirl.create(:user)}
  let(:second_user) {FactoryGirl.create(:user)}
  let(:third_user) {FactoryGirl.create(:user)}

  let!(:group) {
    group = FactoryGirl.create :group, users: [user]
    UserGroup.set_is_admin(group.id, user.id, true)
    group
  }
  let(:second_group) {FactoryGirl.create(:group)}

  let(:course) {FactoryGirl.create(:course)}

  let(:valid_model_attributes) { {author: second_user, is_obligatory: false, groups: [group, second_group], users: [user, third_user], course: course} }
  let(:valid_controller_attributes_group) { {author: user, is_obligatory: false, related_group_ids: "#{group.id}", related_user_ids: "", course_id: course.id} }
  let(:valid_controller_attributes_user) { {author: user, is_obligatory: false, related_user_ids: "#{second_user.id}", related_group_ids: "", course_id: course.id} }
  let(:valid_controller_attributes_multiple_users) { {author: user, is_obligatory: false, related_group_ids: "", related_user_ids: "#{second_user.id}, #{third_user.id}", course_id: course.id} }
  let(:valid_controller_attributes_multiple) { {author: user, is_obligatory: false, related_group_ids: "#{group.id}, #{second_group.id}", related_user_ids: "#{second_user.id}, #{third_user.id}", course_id: course.id} }

  before(:each) do
    sign_in user
  end

  describe "GET index" do
    it "assigns all recommendations as @recommendations" do
      recommendation = Recommendation.create! valid_model_attributes
      get :index, {}
      expect(assigns(:recommendations)[0][0]).to eq(recommendation)
    end
  end


  describe "GET new" do
    it "assigns a new recommendation as @recommendation" do
      get :new, {}
      expect(assigns(:recommendation)).to be_a_new(Recommendation)
    end
  end

  describe "POST create" do
    it "creates a new Recommendation" do
      expect { post :create, {:recommendation => valid_controller_attributes_user} }.to change(Recommendation, :count).by(1)
    end

    it "redirects to dashboard" do
      post :create, {:recommendation => valid_controller_attributes_user}
      expect(response).to redirect_to dashboard_dashboard_path
    end

    it "adds relations to specified groups" do
      post :create, {:recommendation => valid_controller_attributes_group}
      expect(Recommendation.last.group).to eq group
      expect(Recommendation.last.users).to match_array(group.users)
    end

    it "adds relations to specified users" do
      post :create, {:recommendation => valid_controller_attributes_multiple_users}
      expect(Recommendation.first.users).to match_array([third_user])
      expect(Recommendation.last.users).to match_array([second_user])
    end

    it "adds relations to specified course" do
      post :create, {:recommendation => valid_controller_attributes_group}
      expect(Recommendation.last.course).to eql course
    end

    it "should create one recommendation for each specified user or group" do
      expect { post :create, {:recommendation => valid_controller_attributes_multiple}}.to change(Recommendation, :count).by(4)
    end

  end

  describe "GET DELETE" do
    it "should destroy the requested recommendation of current user" do
      recommendation = FactoryGirl.create(:recommendation, users: [user], group: nil)
      expect {
        get :delete, {:id => recommendation.to_param}
      }.to change(Recommendation, :count).by(-1)
    end

    it "should destroy the requested recommendation of specified group" do
      recommendation = FactoryGirl.create(:recommendation, users: [], group: group)
      expect {
        get :delete, id: recommendation.to_param, group: group.id
      }.to change(Recommendation, :count).by(-1)
    end

    it "should remove current user from recommendation but do not delete recommendation" do
      recommendation = FactoryGirl.create(:recommendation, users: [user, second_user], group: nil)
      expect {
        get :delete, {:id => recommendation.to_param}
      }.to change(Recommendation, :count).by(0)
      expect(Recommendation.find(recommendation.id).users).to match_array([second_user])
    end
  end
end

