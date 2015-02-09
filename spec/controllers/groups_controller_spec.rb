require 'rails_helper'

RSpec.describe GroupsController, :type => :controller do

  let(:valid_attributes) { {name: 'Test', description: 'test'} }

  let(:user) {FactoryGirl.create(:user)}
  let!(:group) {FactoryGirl.create(:group, users: [user])}

  before(:each) do
    @request.env["devise.mapping"] = Devise.mappings[:user]
    sign_in user
  end

  describe "GET index" do
    it "assigns all groups as @groups" do
      get :index, {}
      expect(assigns(:groups)).to eq([group])
    end
  end

  describe "GET show" do
    it "assigns the requested group as @group" do
      get :show, {:id => group.to_param}
      expect(assigns(:group)).to eq(group)
    end
  end

  describe "GET new" do
    it "assigns a new group as @group" do
      get :new, {}
      expect(assigns(:group)).to be_a_new(Group)
    end
  end

  describe "GET edit" do
    it "assigns the requested group as @group" do
      get :edit, {:id => group.to_param}
      expect(assigns(:group)).to eq(group)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new Group" do
        expect {
          post :create, {:group => valid_attributes}
        }.to change(Group, :count).by(1)
      end

      it "assigns a newly created group as @group" do
        post :create, {:group => valid_attributes}
        expect(assigns(:group)).to be_a(Group)
        expect(assigns(:group)).to be_persisted
      end

      it "redirects to the created group" do
        post :create, {:group => valid_attributes}
        expect(response).to redirect_to(Group.last)
      end
    end

  end

  describe "PUT update" do
    describe "with valid params" do
      let(:new_attributes) { {name: 'Test_different', description: 'edited text'} }

      it "updates the requested group" do
        put :update, {:id => group.to_param, :group => new_attributes}
        group.reload
        expect(group.name).to eq('Test_different')
        expect(group.description).to eq('edited text')
      end

      it "assigns the requested group as @group" do
        put :update, {:id => group.to_param, :group => FactoryGirl.attributes_for(:group)}
        expect(assigns(:group)).to eq(group)
      end

      it "redirects to the group" do
        put :update, {:id => group.to_param, :group => FactoryGirl.attributes_for(:group)}
        expect(response).to redirect_to(group)
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested group" do
      expect {
        delete :destroy, {:id => group.to_param}
      }.to change(Group, :count).by(-1)
    end

    it "redirects to the groups list" do
      delete :destroy, {:id => group.to_param}
      expect(response).to redirect_to(groups_url)
    end
  end

end
