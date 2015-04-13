require 'rails_helper'

RSpec.describe GroupsController, :type => :controller do

  let(:valid_attributes) { {name: 'Test', description: 'test'} }
  let(:members) { 'test@example.com; test2@example.com' }

  let(:user) {FactoryGirl.create(:user)}
  let!(:group) {FactoryGirl.create(:group, users: [user])}
  let!(:group_with_admin) {
    g = FactoryGirl.create(:group, users: [user])
    UserGroup.set_is_admin(g.id, user.id, true)
    g
  }
  let!(:group_without_user) { FactoryGirl.create :group }
  let(:user_groups) { [group_with_admin, group] }

  before(:each) do
    @request.env["devise.mapping"] = Devise.mappings[:user]
    sign_in user
    ActionMailer::Base.deliveries.clear
  end

  describe "GET index" do
    it "assigns all groups as @groups" do
      get :index, {}
      expect(assigns(:groups)).to match_array(user_groups)
    end
  end

  describe "GET show" do
    it "assigns the requested group as @group" do
      get :show, {:id => group.to_param}
      expect(assigns(:group)).to eq(group)
    end

    context 'without authorization' do
      before(:each) { get :show, {id: group_without_user.id} }
      it 'redirects to groups page' do
        expect(response).to redirect_to(groups_path)
      end

      it 'shows an alert message' do
        expect(flash[:alert]).to eq I18n.t('unauthorized.show.group')
      end
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
      get :edit, {:id => group_with_admin.to_param}
      expect(assigns(:group)).to eq(group_with_admin)
    end

    context 'without authorization' do
      context 'user is not in group' do
        before(:each) { get :edit, {id: group_without_user.id} }
        it 'redirects to groups page' do
          expect(response).to redirect_to(groups_path)
        end

        it 'shows an alert message' do
          expect(flash[:alert]).to eq I18n.t('unauthorized.show.group')
        end
      end

      context 'user is group member but not admin' do
        before(:each) { get :edit, {id: group.id} }
        it 'redirects to groups page' do
          expect(response).to redirect_to(groups_path)
        end

        it 'shows an alert message' do
          expect(flash[:alert]).to eq I18n.t('unauthorized.show.group')
        end
      end
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new Group" do
        expect {
          post :create, {:group => valid_attributes}
        }.to change(Group, :count).by(1)
        expect(flash[:notice]).to eq I18n.t('flash.notice.groups.successfully_created')
      end

      it "assigns a newly created group as @group" do
        post :create, {:group => valid_attributes}
        expect(assigns(:group)).to be_a(Group)
        expect(assigns(:group)).to be_persisted
      end

      it "redirects to the created group" do
        post :create, {:group => valid_attributes}
        group = assigns(:group)
        expect(response).to redirect_to(group_path(group))
      end

      it "assigns the current user to group" do
        post :create, {:group => valid_attributes}
        expect(assigns(:group).users).to include(user)
      end

      it "assigns the current user to group as admin" do
        post :create, {:group => valid_attributes}
        group = assigns(:group)
        expect(@controller.admins).to include(group.users.first)
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      let(:new_attributes) { {name: 'Test_different', description: 'edited text'} }

      it "updates the requested group" do
        put :update, {:id => group_with_admin.to_param, :group => new_attributes}
        group_with_admin.reload
        expect(group_with_admin.name).to eq('Test_different')
        expect(group_with_admin.description).to eq('edited text')
        expect(flash[:notice]).to eq I18n.t('flash.notice.groups.successfully_updated')
      end

      it "assigns the requested group as @group" do
        put :update, {:id => group_with_admin.to_param, :group => FactoryGirl.attributes_for(:group)}
        expect(assigns(:group)).to eq(group_with_admin)
      end

      it "redirects to the group" do
        put :update, {:id => group_with_admin.to_param, :group => FactoryGirl.attributes_for(:group)}
        expect(response).to redirect_to(group_with_admin)
      end

      context 'without authorization' do
        context 'user is not in group' do
          before(:each) { put :update, {id: group_without_user.id} }
          it 'redirects to groups page' do
            expect(response).to redirect_to(groups_path)
          end

          it 'shows an alert message' do
            expect(flash[:alert]).to eq I18n.t('unauthorized.show.group')
          end
        end

        context 'user is group member but not admin' do
          before(:each) { put :update, {id: group.id} }
          it 'redirects to groups page' do
            expect(response).to redirect_to(groups_path)
          end

          it 'shows an alert message' do
            expect(flash[:alert]).to eq I18n.t('unauthorized.show.group')
          end
        end
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested group" do
      expect {
        delete :destroy, {:id => group_with_admin.to_param}
      }.to change(Group, :count).by(-1)
      expect(flash[:notice]).to eq I18n.t('flash.notice.groups.successfully_destroyed')
    end

    it "redirects to the groups list" do
      delete :destroy, {:id => group_with_admin.to_param}
      expect(response).to redirect_to(groups_url)
    end

    it "destroys the membership of all users of the deleted group and only of the deleted group" do
      user_1 = FactoryGirl.create(:user)
      user_2 = FactoryGirl.create(:user)
      group_with_admin.update(users: [user, user_1, user_2])
      group_2 = FactoryGirl.create(:group, users: [user, user_1, user_2])
      expect {
        delete :destroy, {:id => group_with_admin.to_param}
      }.to change(UserGroup, :count).by(-3)
      # users are no longer members of group
      expect(user.groups).not_to include(group_with_admin)
      expect(user_1.groups).not_to include(group_with_admin)
      expect(user_2.groups).not_to include(group_with_admin)
      # users are still members of group_2
      expect(user.groups).to include(group_2)
      expect(user_1.groups).to include(group_2)
      expect(user_2.groups).to include(group_2)
    end

    context 'without authorization' do
      context 'user is not in group' do
        before(:each) { delete :destroy, {id: group_without_user.id} }
        it 'redirects to groups page' do
          expect(response).to redirect_to(groups_path)
        end

        it 'shows an alert message' do
          expect(flash[:alert]).to eq I18n.t('unauthorized.show.group')
        end
      end

      context 'user is group member but not admin' do
        before(:each) { delete :destroy, {id: group.id} }
        it 'redirects to groups page' do
          expect(response).to redirect_to(groups_path)
        end

        it 'shows an alert message' do
          expect(flash[:alert]).to eq I18n.t('unauthorized.show.group')
        end
      end
    end
  end

  describe "admins for a group" do
    it "should returns all administrators for the given group" do
      post :create, {:group => valid_attributes}
      group = assigns(:group)
      user_1 = FactoryGirl.create(:user)
      user_2 = FactoryGirl.create(:user)
      group.users.push(user_1, user_2)
      UserGroup.set_is_admin(group.id, user_1.id, true)
      expect(@controller.admins).to match_array([user, user_1])
    end
  end

  describe "invite members" do
    context "on create" do
      it "should do nothing if there are no members to invite" do
        post :create, {group: valid_attributes}
        expect(GroupInvitation.count).to eq 0
        expect(ActionMailer::Base.deliveries.count).to eq 0
      end

      it "should invite members" do
        expect{ post :create, {group: valid_attributes, members: members} }.to change{ GroupInvitation.count }.by(2)
        expect(ActionMailer::Base.deliveries.count).to eq 2
      end

      it "should split invite members string correctly to email array" do
        email_string = "test1@example.com test2@example.com,test3@example.com, test4@example.com;test5@example.com; test6@example.com  test7@example.com\ntest8@example.com"
        post :create, {group: valid_attributes, members: email_string}
        ActionMailer::Base.deliveries.each_with_index do |delivery, i|
          expect(delivery.to).to contain_exactly("test#{i+1}@example.com")
        end
        expect(ActionMailer::Base.deliveries.count).to eq 8
      end

    end

    context "on update" do
      it "should do nothing if there are no members to invite" do
        put :update, {id: group_with_admin.id, group: valid_attributes}
        expect(GroupInvitation.count).to eq 0
        expect(ActionMailer::Base.deliveries.count).to eq 0
      end

      it "should invite members" do
        expect{ put :update, {id: group_with_admin.id, group: valid_attributes, members: members} }.to change{ GroupInvitation.count }.by(2)
        expect(ActionMailer::Base.deliveries.count).to eq 2
      end
    end

    context "on show page" do
      it "should do nothing if there are no members to invite" do
        put :invite_group_members, {id: group_with_admin.id, group: valid_attributes}
        expect(GroupInvitation.count).to eq 0
        expect(ActionMailer::Base.deliveries.count).to eq 0
      end

      it "should invite members" do
        expect{ put :invite_group_members, {id: group_with_admin.id, group: valid_attributes, members: members} }.to change{ GroupInvitation.count }.by(2)
        expect(ActionMailer::Base.deliveries.count).to eq 2
      end

      context 'without authorization' do
        context 'user is not in group' do
          before(:each) { put :invite_group_members, {id: group_without_user.id, group: valid_attributes} }
          it 'redirects to groups page' do
            expect(response).to redirect_to(groups_path)
          end

          it 'shows an alert message' do
            expect(flash[:alert]).to eq I18n.t('unauthorized.show.group')
          end
        end

        context 'user is group member but not admin' do
          before(:each) { put :invite_group_members, {id: group.id, group: valid_attributes} }
          it 'redirects to groups page' do
            expect(response).to redirect_to(groups_path)
          end

          it 'shows an alert message' do
            expect(flash[:alert]).to eq I18n.t('unauthorized.show.group')
          end
        end
      end
    end
  end

  describe "GET join" do
    let(:another_group) { FactoryGirl.create :group, users: [user] }
    let(:unjoined_group) { FactoryGirl.create :group }
    let!(:invitation) { FactoryGirl.create :group_invitation, group: unjoined_group }
    let(:expired_invitation) { FactoryGirl.create :group_invitation, group: unjoined_group, expiry_date: 1.day.ago.in_time_zone }

    it "should add member to group" do
      get :join, token: invitation.token
      expect(response).to redirect_to(group_path(unjoined_group))
      expect(Group.find(unjoined_group.id).users).to include(user)
      expect(GroupInvitation.find(invitation.id).used).to be true
      expect(flash[:success]).to eq I18n.t('groups.invitation.joined_group')
    end

    it "should not allow to use link twice" do
      get :join, token: invitation.token
      group_users_before = Group.find(unjoined_group.id).users.count
      get :join, token: invitation.token
      expect(response).to redirect_to(root_path)
      expect(flash[:error]).to eq I18n.t('groups.invitation.link_used')
      expect(Group.find(unjoined_group.id).users.count).to eq group_users_before
    end

    it "should not add user with expired invitation" do
      get :join, token: expired_invitation.token
      expect(response).to redirect_to(root_path)
      expect(flash[:error]).to eql I18n.t('groups.invitation.link_expired')
      expect(Group.find(unjoined_group.id).users.count).to eq unjoined_group.users.count
    end

    it "should not add user to deleted group" do
      unjoined_group.users.push(user)
      UserGroup.set_is_admin(unjoined_group.id, user.id, true)
      delete :destroy, {id: unjoined_group.to_param}
      another_user = FactoryGirl.create(:user)
      sign_in(another_user)
      get :join, token: invitation.token
      expect(response).to redirect_to(root_path)
      expect(flash[:error]).to eql I18n.t('groups.invitation.group_deleted')
    end

    it "should not add member twice" do
      unjoined_group.users.push(user)
      get :join, token: invitation.token
      expect(response).to redirect_to(group_path(unjoined_group))
      expect(flash[:notice]).to eq I18n.t('groups.invitation.already_member')
      expect(GroupInvitation.find(invitation.id).used).to be true
      expect(Group.find(unjoined_group.id).users.where(id: user.id).count).to eq 1
    end

    it "should display error message if token is invalid" do
      get :join, token: "132465798"
      expect(response).to redirect_to(root_path)
      expect(flash[:error]).to eq I18n.t('groups.invitation.link_invalid')
    end
  end

  describe "POST add_administrators" do
    let(:user) {FactoryGirl.create(:user)}
    let(:second_user) {FactoryGirl.create(:user)}
    let(:group) {FactoryGirl.create(:group, users:[user, second_user])}
    let(:new_admin) {
      new_admin = FactoryGirl.create(:user)
      group.users.push(new_admin)
      new_admin
    }

    it "should add one administrator to an existing group" do
      UserGroup.set_is_admin(group.id, user.id, true)
      put :add_administrator, {id: group.id, group: valid_attributes, additional_administrator: new_admin}
      expect(response).to redirect_to group_path(group)
      current_admins_of_group = UserGroup.where(group_id: group.id, is_admin: true)
      expect(current_admins_of_group.count).to eq 2
    end

    context 'without authorization' do
      context 'user is not in group' do
        before(:each) { put :add_administrator, {id: group_without_user.id, group: valid_attributes, additional_administrator: new_admin} }
        it 'redirects to groups page' do
          expect(response).to redirect_to(groups_path)
        end

        it 'shows an alert message' do
          expect(flash[:alert]).to eq I18n.t('unauthorized.show.group')
        end
      end

      context 'user is group member but not admin' do
        before(:each) { put :add_administrator, {id: group.id, group: valid_attributes, additional_administrator: new_admin} }
        it 'redirects to groups page' do
          expect(response).to redirect_to(groups_path)
        end

        it 'shows an alert message' do
          expect(flash[:alert]).to eq I18n.t('unauthorized.show.group')
        end
      end
    end
  end

  describe "POST demote_administrator" do
    let(:user) {FactoryGirl.create(:user)}
    let(:group) {FactoryGirl.create(:group, users:[user])}

    it "should demote an administrator to a normal memeber" do
      UserGroup.set_is_admin(group.id, user.id, true)
      expect{ put :demote_administrator, {id: group.id, demoted_admin: user} }.to change(UserGroup.where(group_id: group.id, is_admin: true), :count).by(-1)
      expect(response).to redirect_to group_path(group)
    end

    context 'without authorization' do
      context 'user is not in group' do
        before(:each) { put :demote_administrator, {id: group_without_user.id, demote_admin: user} }
        it 'redirects to groups page' do
          expect(response).to redirect_to(groups_path)
        end

        it 'shows an alert message' do
          expect(flash[:alert]).to eq I18n.t('unauthorized.show.group')
        end
      end

      context 'user is group member but not admin' do
        before(:each) { put :demote_administrator, {id: group.id, demote_admin: user} }
        it 'redirects to groups page' do
          expect(response).to redirect_to(groups_path)
        end

        it 'shows an alert message' do
          expect(flash[:alert]).to eq I18n.t('unauthorized.show.group')
        end
      end
    end
  end

  describe  "POST remove group member" do
    let(:user) {FactoryGirl.create(:user)}
    let(:second_user) {FactoryGirl.create(:user)}
    let(:third_user) {FactoryGirl.create(:user)}
    let(:group) {FactoryGirl.create(:group, users:[user, second_user, third_user])}

    it "should remove a member of a group" do
      UserGroup.set_is_admin(group.id, user.id, true)
      admins_of_group = UserGroup.where(group_id: group.id, is_admin: true)
      expect{ put :remove_group_member, {id: group.id, removing_member: user.id } }.to change{group.users.count}.by(-1)
      expect(admins_of_group).to eq(UserGroup.where(group_id: group.id, is_admin: true))
    end

    context 'without authorization' do
      context 'user is not in group' do
        before(:each) { put :remove_group_member, {id: group_without_user.id, removing_member: user.id} }
        it 'redirects to groups page' do
          expect(response).to redirect_to(groups_path)
        end

        it 'shows an alert message' do
          expect(flash[:alert]).to eq I18n.t('unauthorized.show.group')
        end
      end

      context 'user is group member but not admin' do
        before(:each) { put :remove_group_member, {id: group.id, removing_member: user.id} }
        it 'redirects to groups page' do
          expect(response).to redirect_to(groups_path)
        end

        it 'shows an alert message' do
          expect(flash[:alert]).to eq I18n.t('unauthorized.show.group')
        end
      end
    end
  end


  describe "POST condition for changing member status" do
    let(:user) {FactoryGirl.create(:user)}
    let(:second_user) {FactoryGirl.create(:user)}
    let(:third_user) {FactoryGirl.create(:user)}
    let(:group) {FactoryGirl.create(:group, users:[user, second_user, third_user])}
    let(:second_group) {FactoryGirl.create(:group, users:[user])}

    render_views
    let(:json) { JSON.parse(response.body) }

    it "should return 'last_admin' if the member is the last admin (but there are still other members)" do
      UserGroup.set_is_admin(group.id, user.id, true)
      post :condition_for_changing_member_status, format: :json, id: group.id, changing_member: user.id
      expect(response.body).to have_content('last_admin')
    end

    it "should return 'last_member' if the member is the last member" do
      UserGroup.set_is_admin(second_group.id, user.id, true)
      post :condition_for_changing_member_status, format: :json, id: second_group.id, changing_member: user.id
      expect(response.body).to have_content('last_member')
    end

    it "should return 'ok' if there are no restrictions to remove the member" do
      UserGroup.set_is_admin(group.id, user.id, true)
      post :condition_for_changing_member_status, format: :json, id: group.id, changing_member: second_user.id
      expect(response.body).to have_content('ok')
    end


  end

  describe "POST all members to administrators" do
    let(:user) {FactoryGirl.create(:user)}
    let(:second_user) {FactoryGirl.create(:user)}
    let(:third_user) {FactoryGirl.create(:user)}
    let(:group) {FactoryGirl.create(:group, users:[user, second_user, third_user])}

    it "should make all members of a group to admins" do
      UserGroup.set_is_admin(group.id, user.id, true)
      put :all_members_to_administrators, {id: group.id}
      current_admins_of_group = UserGroup.where(group_id: group.id, is_admin: true)
      expect(current_admins_of_group.count).to eq(group.users.count)
    end

    context 'without authorization' do
      context 'user is not in group' do
        before(:each) { put :all_members_to_administrators, {id: group_without_user.id} }
        it 'redirects to groups page' do
          expect(response).to redirect_to(groups_path)
        end

        it 'shows an alert message' do
          expect(flash[:alert]).to eq I18n.t('unauthorized.show.group')
        end
      end

      context 'user is group member but not admin' do
        before(:each) { put :all_members_to_administrators, {id: group.id} }
        it 'redirects to groups page' do
          expect(response).to redirect_to(groups_path)
        end

        it 'shows an alert message' do
          expect(flash[:alert]).to eq I18n.t('unauthorized.show.group')
        end
      end
    end
  end
end
