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

      it "assigns the current user to group" do
        post :create, {:group => valid_attributes}
        expect(assigns(:group).users).to include(user)
      end

      it "assigns the current user to group as admin" do
        post :create, {:group => valid_attributes}
        group = assigns(:group)
        admin_ids = UserGroup.where(group_id: group.id, is_admin: true).collect{|user_groups| user_groups.user_id}
        expect(admin_ids).to include(group.users.first.id)
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

    it "destroys the membership of all users of the deleted group and only of the deleted group" do
      user_1 = FactoryGirl.create(:user, email: 'max@test.de')
      user_2 = FactoryGirl.create(:user, email: 'max@test.com')
      group.update(users: [user, user_1, user_2])
      group_2 = FactoryGirl.create(:group, users: [user, user_1, user_2])
      expect {
        delete :destroy, {:id => group.to_param}
      }.to change(UserGroup, :count).by(-3)
      # users are no longer members of group
      expect(user.groups).not_to include(group)
      expect(user_1.groups).not_to include(group)
      expect(user_2.groups).not_to include(group)
      # users are still members of group_2
      expect(user.groups).to include(group_2)
      expect(user_1.groups).to include(group_2)
      expect(user_2.groups).to include(group_2)
    end
  end

end
