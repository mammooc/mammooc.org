require 'rails_helper'

RSpec.describe RecommendationsController, :type => :controller do

  let(:user) {FactoryGirl.create(:user)}
  let(:second_user) {FactoryGirl.create(:user)}
  let(:third_user) {FactoryGirl.create(:user)}

  let(:group) {FactoryGirl.create(:group)}
  let(:second_group) {FactoryGirl.create(:group)}

  let(:course) {FactoryGirl.create(:course)}

  let(:valid_model_attributes) { {user: user, is_obligatory: false, groups: [group, second_group], users: [second_user, third_user], course: course} }
  let(:valid_controller_attributes) { {user: user, is_obligatory: false, related_group_ids: "#{group.id} #{second_group.id}", related_user_ids: "#{second_user.id} #{third_user.id}", course_id: course.id} }

  before(:each) do
    sign_in user
  end

  describe "GET index" do
    it "assigns all recommendations as @recommendations" do
      recommendation = Recommendation.create! valid_model_attributes
      get :index, {}
      expect(assigns(:recommendations)).to eq([recommendation])
    end
  end

  describe "GET show" do
    it "assigns the requested recommendation as @recommendation" do
      recommendation = Recommendation.create! valid_model_attributes
      get :show, {:id => recommendation.to_param}
      expect(assigns(:recommendation)).to eq(recommendation)
    end
  end

  describe "GET new" do
    it "assigns a new recommendation as @recommendation" do
      get :new, {}
      expect(assigns(:recommendation)).to be_a_new(Recommendation)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new Recommendation" do
        expect {
          post :create, {:recommendation => valid_controller_attributes}
        }.to change(Recommendation, :count).by(1)
      end

      it "assigns a newly created recommendation as @recommendation" do
        post :create, {:recommendation => valid_controller_attributes}
        expect(assigns(:recommendation)).to be_a(Recommendation)
        expect(assigns(:recommendation)).to be_persisted
      end

      it "redirects to the created recommendation" do
        post :create, {:recommendation => valid_controller_attributes}
        expect(response).to redirect_to(Recommendation.last)
      end

      it "adds relations to specified groups" do
        post :create, {:recommendation => valid_controller_attributes}
        expect(assigns(:recommendation).groups).to match_array([group, second_group])
      end

      it "adds relations to specified users" do
        post :create, {:recommendation => valid_controller_attributes}
        expect(assigns(:recommendation).users).to match_array([second_user, third_user])
      end

      it "adds relations to specified course" do
        post :create, {:recommendation => valid_controller_attributes}
        expect(assigns(:recommendation).course).to eql course
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested recommendation" do
      recommendation = Recommendation.create! valid_model_attributes
      expect {
        delete :destroy, {:id => recommendation.to_param}
      }.to change(Recommendation, :count).by(-1)
    end

    it "redirects to the recommendations list" do
      recommendation = Recommendation.create! valid_model_attributes
      delete :destroy, {:id => recommendation.to_param}
      expect(response).to redirect_to(recommendations_url)
    end
  end

end

