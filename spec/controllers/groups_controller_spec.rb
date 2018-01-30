# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GroupsController, type: :controller do
  let(:valid_attributes) { {name: 'Test', description: 'test'} }
  let(:members) { 'test@example.com; test2@example.com' }

  let(:user) { FactoryBot.create(:user) }
  let!(:group) { FactoryBot.create(:group, users: [user]) }
  let!(:group_with_admin) do
    group = FactoryBot.create(:group, users: [user])
    UserGroup.set_is_admin(group.id, user.id, true)
    group
  end
  let!(:group_without_user) { FactoryBot.create :group }
  let(:user_groups) { [group_with_admin, group] }

  before do
    request.env['devise.mapping'] = Devise.mappings[:user]
    sign_in user
    ActionMailer::Base.deliveries.clear
  end

  describe 'GET index' do
    it 'assigns all groups as @groups' do
      get :index, params: {}
      expect(assigns(:groups)).to match_array(user_groups)
    end

    context 'with name filter' do
      it 'filters correctly' do
        get :index, params: {q: group.name}
        expect(assigns(:groups)).to match_array([group])
      end
    end
  end

  describe 'GET show' do
    it 'assigns the requested group as @group' do
      get :show, params: {id: group.to_param}
      expect(assigns(:group)).to eq(group)
    end

    context 'without authorization' do
      before { get :show, params: {id: group_without_user.id} }
      it 'redirects to groups page' do
        expect(response).to redirect_to(groups_path)
      end

      it 'shows an alert message' do
        expect(flash[:alert]).to eq I18n.t('unauthorized.show.group')
      end
    end

    describe 'check activities' do
      let!(:user2) { FactoryBot.create(:user) }
      let!(:group) { FactoryBot.create(:group, users: [user, user2]) }

      it 'only shows activities from my group members' do
        user3 = FactoryBot.create(:user)
        FactoryBot.create(:group, users: [user, user3])
        user4 = FactoryBot.create(:user)
        user4_activity = FactoryBot.create(:activity_bookmark, owner: user4, group_ids: [group.id])
        user3_activity = FactoryBot.create(:activity_bookmark, owner: user3, group_ids: [group.id])
        user2_activity = FactoryBot.create(:activity_bookmark, owner: user2, group_ids: [group.id])
        get :show, params: {id: group.to_param}
        expect(assigns(:activities)).not_to include(user3_activity)
        expect(assigns(:activities)).to include(user2_activity)
        expect(assigns(:activities)).not_to include(user4_activity)
      end

      it 'does not filter out my own activities' do
        my_activity = FactoryBot.create(:activity_bookmark, owner: user, group_ids: [group.id])
        get :show, params: {id: group.to_param}
        expect(assigns(:activities)).to include(my_activity)
      end

      it 'filters out activities not directed my groups' do
        activity_to_me = FactoryBot.create(:activity_bookmark, owner: user2, user_ids: [user.id])
        activity_to_my_group = FactoryBot.create(:activity_bookmark, owner: user2, group_ids: [group.id])
        activity_without_me = FactoryBot.create(:activity_bookmark, owner: user2)
        get :show, params: {id: group.to_param}
        expect(assigns(:activities)).not_to include(activity_to_me)
        expect(assigns(:activities)).to include(activity_to_my_group)
        expect(assigns(:activities)).not_to include(activity_without_me)
      end

      it 'does not filter any trackable_type of activity' do
        activity_bookmark = FactoryBot.create(:activity_bookmark, owner: user2, group_ids: [group.id])
        activity_group_join = FactoryBot.create(:activity_group_join, owner: user2, group_ids: [group.id])
        activity_course_enroll = FactoryBot.create(:activity_course_enroll, owner: user2, group_ids: [group.id])
        activity_group_recommendation = FactoryBot.create(:activity_group_recommendation, owner: user2, group_ids: [group.id])
        activity_user_recommendation = FactoryBot.create(:activity_user_recommendation, owner: user2, group_ids: [group.id])
        user_setting = FactoryBot.create(:user_setting, name: :course_enrollments_visibility, user: user2)
        FactoryBot.create(:user_setting_entry, setting: user_setting, key: 'groups', value: [group.id])

        get :show, params: {id: group.to_param}

        expect(assigns(:activities)).to include(activity_bookmark)
        expect(assigns(:activities)).to include(activity_group_join)
        expect(assigns(:activities)).to include(activity_course_enroll)
        expect(assigns(:activities)).to include(activity_group_recommendation)
        expect(assigns(:activities)).to include(activity_user_recommendation)
      end
    end
  end

  describe 'GET recommendations' do
    it 'assigns the requested group as @group' do
      get :recommendations, params: {id: group.to_param}
      expect(assigns(:group)).to eq(group)
    end

    context 'without authorization' do
      before { get :recommendations, params: {id: group_without_user.id} }
      it 'redirects to groups page' do
        expect(response).to redirect_to(groups_path)
      end

      it 'shows an alert message' do
        expect(flash[:alert]).to eq I18n.t('unauthorized.show.group')
      end
    end

    describe 'check activities' do
      let!(:user2) { FactoryBot.create(:user) }
      let!(:group) { FactoryBot.create(:group, users: [user, user2]) }

      it 'only shows activities from my group members' do
        user3 = FactoryBot.create(:user)
        FactoryBot.create(:group, users: [user, user3])
        user4 = FactoryBot.create(:user)
        user4_activity = FactoryBot.create(:activity_group_recommendation, owner: user4, group_ids: [group.id])
        user3_activity = FactoryBot.create(:activity_group_recommendation, owner: user3, group_ids: [group.id])
        user2_activity = FactoryBot.create(:activity_group_recommendation, owner: user2, group_ids: [group.id])
        get :recommendations, params: {id: group.to_param}
        expect(assigns(:activities)).not_to include(user3_activity)
        expect(assigns(:activities)).to include(user2_activity)
        expect(assigns(:activities)).not_to include(user4_activity)
      end

      it 'does not filter out my own activities' do
        my_activity = FactoryBot.create(:activity_group_recommendation, owner: user, group_ids: [group.id])
        get :recommendations, params: {id: group.to_param}
        expect(assigns(:activities)).to include(my_activity)
      end

      it 'filters out activities not directed at my groups' do
        activity_to_me = FactoryBot.create(:activity_group_recommendation, owner: user2, user_ids: [user.id])
        activity_to_my_group = FactoryBot.create(:activity_group_recommendation, owner: user2, group_ids: [group.id])
        activity_without_me = FactoryBot.create(:activity_group_recommendation, owner: user2)
        get :recommendations, params: {id: group.to_param}
        expect(assigns(:activities)).not_to include(activity_to_me)
        expect(assigns(:activities)).to include(activity_to_my_group)
        expect(assigns(:activities)).not_to include(activity_without_me)
      end

      it 'filters out anything that is not a group_recommendation activity' do
        activity_bookmark = FactoryBot.create(:activity_bookmark, owner: user2, group_ids: [group.id])
        activity_group_join = FactoryBot.create(:activity_group_join, owner: user2, group_ids: [group.id])
        activity_course_enroll = FactoryBot.create(:activity_course_enroll, owner: user2, group_ids: [group.id])
        activity_group_recommendation = FactoryBot.create(:activity_group_recommendation, owner: user2, group_ids: [group.id])

        get :recommendations, params: {id: group.to_param}

        expect(assigns(:activities)).not_to include(activity_bookmark)
        expect(assigns(:activities)).not_to include(activity_group_join)
        expect(assigns(:activities)).not_to include(activity_course_enroll)
        expect(assigns(:activities)).to include(activity_group_recommendation)
      end
    end
  end

  describe 'GET new' do
    it 'assigns a new group as @group' do
      get :new, params: {}
      expect(assigns(:group)).to be_a_new(Group)
    end
  end

  describe 'GET edit' do
    it 'assigns the requested group as @group' do
      get :edit, params: {id: group_with_admin.to_param}
      expect(assigns(:group)).to eq(group_with_admin)
    end

    context 'without authorization' do
      context 'user is not in group' do
        before { get :edit, params: {id: group_without_user.id} }
        it 'redirects to groups page' do
          expect(response).to redirect_to(groups_path)
        end

        it 'shows an alert message' do
          expect(flash[:alert]).to eq I18n.t('unauthorized.edit.group')
        end
      end

      context 'user is group member but not admin' do
        before { get :edit, params: {id: group.id} }
        it 'redirects to groups page' do
          expect(response).to redirect_to(groups_path)
        end

        it 'shows an alert message' do
          expect(flash[:alert]).to eq I18n.t('unauthorized.edit.group')
        end
      end
    end
  end

  describe 'POST create' do
    describe 'with valid params' do
      it 'creates a new Group' do
        expect do
          post :create, params: {group: valid_attributes}
        end.to change(Group, :count).by(1)
        expect(flash[:notice]).to eq I18n.t('flash.notice.groups.successfully_created')
      end

      it 'assigns a newly created group as @group' do
        post :create, params: {group: valid_attributes}
        expect(assigns(:group)).to be_a(Group)
        expect(assigns(:group)).to be_persisted
      end

      it 'redirects to the created group' do
        post :create, params: {group: valid_attributes}
        group = assigns(:group)
        expect(response).to redirect_to(group_path(group))
      end

      it 'assigns the current user to group' do
        post :create, params: {group: valid_attributes}
        expect(assigns(:group).users).to include(user)
      end

      it 'assigns the current user to group as admin' do
        post :create, params: {group: valid_attributes}
        group = assigns(:group)
        expect(controller.admins).to include(group.users.first)
      end
    end
  end

  describe 'PUT update' do
    describe 'with valid params' do
      let(:new_attributes) { {name: 'Test_different', description: 'edited text'} }

      it 'updates the requested group' do
        put :update, params: {id: group_with_admin.to_param, group: new_attributes}
        group_with_admin.reload
        expect(group_with_admin.name).to eq('Test_different')
        expect(group_with_admin.description).to eq('edited text')
        expect(flash[:notice]).to eq I18n.t('flash.notice.groups.successfully_updated')
      end

      it 'assigns the requested group as @group' do
        put :update, params: {id: group_with_admin.to_param, group: FactoryBot.attributes_for(:group)}
        expect(assigns(:group)).to eq(group_with_admin)
      end

      it 'redirects to the group' do
        put :update, params: {id: group_with_admin.to_param, group: FactoryBot.attributes_for(:group)}
        expect(response).to redirect_to(group_with_admin)
      end

      context 'without authorization' do
        context 'user is not in group' do
          before { put :update, params: {id: group_without_user.id} }
          it 'redirects to groups page' do
            expect(response).to redirect_to(groups_path)
          end

          it 'shows an alert message' do
            expect(flash[:alert]).to eq I18n.t('unauthorized.edit.group')
          end
        end

        context 'user is group member but not admin' do
          before { put :update, params: {id: group.id} }
          it 'redirects to groups page' do
            expect(response).to redirect_to(groups_path)
          end

          it 'shows an alert message' do
            expect(flash[:alert]).to eq I18n.t('unauthorized.edit.group')
          end
        end
      end
    end
  end

  describe 'DELETE destroy' do
    it 'destroys the requested group' do
      expect do
        delete :destroy, params: {id: group_with_admin.to_param}
      end.to change(Group, :count).by(-1)
      expect(flash[:notice]).to eq I18n.t('flash.notice.groups.successfully_destroyed')
    end

    it 'redirects to the groups list' do
      delete :destroy, params: {id: group_with_admin.to_param}
      expect(response).to redirect_to(groups_url)
    end

    it 'destroys the membership of all users of the deleted group and only of the deleted group' do
      user1 = FactoryBot.create(:user)
      user2 = FactoryBot.create(:user)
      group_with_admin.users = [user, user1, user2]
      group2 = FactoryBot.create(:group, users: [user, user1, user2])
      expect do
        delete :destroy, params: {id: group_with_admin.to_param}
      end.to change(UserGroup, :count).by(-3)
      # users are no longer members of group
      expect(user.groups).not_to include(group_with_admin)
      expect(user1.groups).not_to include(group_with_admin)
      expect(user2.groups).not_to include(group_with_admin)
      # users are still members of group2
      expect(user.groups).to include(group2)
      expect(user1.groups).to include(group2)
      expect(user2.groups).to include(group2)
    end

    context 'without authorization' do
      context 'user is not in group' do
        before { delete :destroy, params: {id: group_without_user.id} }
        it 'redirects to groups page' do
          expect(response).to redirect_to(groups_path)
        end

        it 'shows an alert message' do
          expect(flash[:alert]).to eq I18n.t('unauthorized.edit.group')
        end
      end

      context 'user is group member but not admin' do
        before { delete :destroy, params: {id: group.id} }
        it 'redirects to groups page' do
          expect(response).to redirect_to(groups_path)
        end

        it 'shows an alert message' do
          expect(flash[:alert]).to eq I18n.t('unauthorized.edit.group')
        end
      end
    end
  end

  describe 'admins for a group' do
    it 'returnses all administrators for the given group' do
      post :create, params: {group: valid_attributes}
      group = assigns(:group)
      user1 = FactoryBot.create(:user)
      user2 = FactoryBot.create(:user)
      group.users.push(user1, user2)
      UserGroup.set_is_admin(group.id, user1.id, true)
      expect(controller.admins).to match_array([user, user1])
    end
  end

  describe 'invite members' do
    render_views
    let(:json) { JSON.parse(response.body) }

    it 'does nothing if there are no members to invite' do
      post :invite_group_members, params: {format: :json, id: group_with_admin.id, members: ''}
      expect(GroupInvitation.count).to eq 0
      expect(response.body).to have_content('"error_email":[]')
      expect(ActionMailer::Base.deliveries.count).to eq 0
    end

    it 'splits invite members string correctly to email array' do
      email_string = "test1@example.com test2@example.com,test3@example.com, test4@example.com;test5@example.com; test6@example.com  test7@example.com\ntest8@example.com"
      post :invite_group_members, params: {format: :json, id: group_with_admin.id, members: email_string}
      ActionMailer::Base.deliveries.each_with_index do |delivery, i|
        expect(delivery.to).to contain_exactly("test#{i + 1}@example.com")
      end
      expect(response.body).to have_content('"error_email":[]')
      expect(ActionMailer::Base.deliveries.count).to eq 8
    end

    it 'invites members' do
      expect { post :invite_group_members, params: {format: :json, id: group_with_admin.id, members: members} }.to change(GroupInvitation, :count).by(2)
      expect(response.body).to have_content('"error_email":[]')
      expect(ActionMailer::Base.deliveries.count).to eq 2
    end

    it 'returns wrong email addresses' do
      email_string = members + ', wrong; misspelled valid@example.org'
      expect { post :invite_group_members, params: {format: :json, id: group_with_admin.id, members: email_string} }.to change(GroupInvitation, :count).by(3)
      expect(response.body).to have_content('"error_email":["wrong","misspelled"]')
      expect(ActionMailer::Base.deliveries.count).to eq 3
    end

    context 'with first token not valid' do
      let(:group) { FactoryBot.create :group }
      let!(:group_invitation) { FactoryBot.create :group_invitation, token: 'b4GOKm4pOYU_-BOXcrUGDg', group: group }

      before do
        allow(SecureRandom).to receive(:urlsafe_base64).and_return('b4GOKm4pOYU_-BOXcrUGDg', 'ZLdOkzop70Ddx-IJR0ABg')
      end

      it 'invites member' do
        email_string = 'valid@example.org'
        expect { post :invite_group_members, params: {format: :json, id: group_with_admin.id, members: email_string} }.to change(GroupInvitation, :count).by(1)
        expect(response.body).to have_content('"error_email":[]')
        expect(ActionMailer::Base.deliveries.count).to eq 1
        expect(GroupInvitation.find_by(token: 'ZLdOkzop70Ddx-IJR0ABg')).not_to eq nil
      end
    end

    context 'without authorization' do
      context 'user is not in group' do
        before { put :invite_group_members, params: {id: group_without_user.id, group: valid_attributes} }
        it 'redirects to groups page' do
          expect(response).to redirect_to(groups_path)
        end

        it 'shows an alert message' do
          expect(flash[:alert]).to eq I18n.t('unauthorized.edit.group')
        end
      end

      context 'user is group member but not admin' do
        before { put :invite_group_members, params: {id: group.id, group: valid_attributes} }
        it 'redirects to groups page' do
          expect(response).to redirect_to(groups_path)
        end

        it 'shows an alert message' do
          expect(flash[:alert]).to eq I18n.t('unauthorized.edit.group')
        end
      end
    end
  end

  describe 'GET join' do
    let(:another_group) { FactoryBot.create :group, users: [user] }
    let(:unjoined_group) { FactoryBot.create :group }
    let!(:invitation) { FactoryBot.create :group_invitation, group: unjoined_group }
    let(:expired_invitation) { FactoryBot.create :group_invitation, group: unjoined_group, expiry_date: 1.day.ago.in_time_zone }

    it 'adds member to group' do
      get :join, params: {token: invitation.token}
      expect(response).to redirect_to(group_path(unjoined_group))
      expect(Group.find(unjoined_group.id).users).to include(user)
      expect(GroupInvitation.find(invitation.id).used).to be true
      expect(flash[:success]).to eq I18n.t('groups.invitation.joined_group')
    end

    it 'creates a group.join activity' do
      expect do
        get :join, params: {token: invitation.token}
      end.to change(PublicActivity::Activity, :count).by(1)
    end

    it 'does not allow to use link twice' do
      get :join, params: {token: invitation.token}
      group_users_before = Group.find(unjoined_group.id).users.count
      get :join, params: {token: invitation.token}
      expect(response).to redirect_to(root_path)
      expect(flash[:error]).to eq I18n.t('groups.invitation.link_used')
      expect(Group.find(unjoined_group.id).users.count).to eq group_users_before
    end

    it 'does not add user with expired invitation' do
      get :join, params: {token: expired_invitation.token}
      expect(response).to redirect_to(root_path)
      expect(flash[:error]).to eq I18n.t('groups.invitation.link_expired')
      expect(Group.find(unjoined_group.id).users.count).to eq unjoined_group.users.count
    end

    it 'does not add user to deleted group' do
      unjoined_group.users.push(user)
      UserGroup.set_is_admin(unjoined_group.id, user.id, true)
      delete :destroy, params: {id: unjoined_group.to_param}
      another_user = FactoryBot.create(:user)
      sign_in(another_user)
      get :join, params: {token: invitation.token}
      expect(response).to redirect_to(root_path)
      expect(flash[:error]).to eq I18n.t('groups.invitation.group_deleted')
    end

    it 'does not add member twice' do
      unjoined_group.users.push(user)
      get :join, params: {token: invitation.token}
      expect(response).to redirect_to(group_path(unjoined_group))
      expect(flash[:notice]).to eq I18n.t('groups.invitation.already_member')
      expect(GroupInvitation.find(invitation.id).used).to be true
      expect(Group.find(unjoined_group.id).users.where(id: user.id).count).to eq 1
    end

    it 'displays error message if token is invalid' do
      get :join, params: {token: '132465798'}
      expect(response).to redirect_to(root_path)
      expect(flash[:error]).to eq I18n.t('groups.invitation.link_invalid')
    end
  end

  describe 'POST add_administrators' do
    let(:user) { FactoryBot.create(:user) }
    let(:second_user) { FactoryBot.create(:user) }
    let(:group) { FactoryBot.create(:group, users: [user, second_user]) }
    let(:new_admin) do
      new_admin = FactoryBot.create(:user)
      group.users.push(new_admin)
      new_admin
    end

    it 'adds one administrator to an existing group' do
      UserGroup.set_is_admin(group.id, user.id, true)
      put :add_administrator, params: {id: group.id, group: valid_attributes, additional_administrator: new_admin}
      expect(response).to redirect_to group_path(group)
      current_admins_of_group = UserGroup.where(group_id: group.id, is_admin: true)
      expect(current_admins_of_group.count).to eq 2
    end

    context 'without authorization' do
      context 'user is not in group' do
        before { put :add_administrator, params: {id: group_without_user.id, group: valid_attributes, additional_administrator: new_admin} }
        it 'redirects to groups page' do
          expect(response).to redirect_to(groups_path)
        end

        it 'shows an alert message' do
          expect(flash[:alert]).to eq I18n.t('unauthorized.edit.group')
        end
      end

      context 'user is group member but not admin' do
        before { put :add_administrator, params: {id: group.id, group: valid_attributes, additional_administrator: new_admin} }
        it 'redirects to groups page' do
          expect(response).to redirect_to(groups_path)
        end

        it 'shows an alert message' do
          expect(flash[:alert]).to eq I18n.t('unauthorized.edit.group')
        end
      end
    end
  end

  describe 'POST demote_administrator' do
    let(:user) { FactoryBot.create(:user) }
    let(:group) { FactoryBot.create(:group, users: [user]) }

    it 'demotes an administrator to a normal memeber' do
      UserGroup.set_is_admin(group.id, user.id, true)
      expect { put :demote_administrator, params: {id: group.id, demoted_admin: user} }.to change(UserGroup.where(group_id: group.id, is_admin: true), :count).by(-1)
      expect(response).to redirect_to group_path(group)
    end

    context 'without authorization' do
      context 'user is not in group' do
        before { put :demote_administrator, params: {id: group_without_user.id, demote_admin: user} }
        it 'redirects to groups page' do
          expect(response).to redirect_to(groups_path)
        end

        it 'shows an alert message' do
          expect(flash[:alert]).to eq I18n.t('unauthorized.edit.group')
        end
      end

      context 'user is group member but not admin' do
        before { put :demote_administrator, params: {id: group.id, demote_admin: user} }
        it 'redirects to groups page' do
          expect(response).to redirect_to(groups_path)
        end

        it 'shows an alert message' do
          expect(flash[:alert]).to eq I18n.t('unauthorized.edit.group')
        end
      end
    end
  end

  describe 'POST remove group member' do
    let(:user) { FactoryBot.create(:user) }
    let(:second_user) { FactoryBot.create(:user) }
    let(:third_user) { FactoryBot.create(:user) }
    let(:group) { FactoryBot.create(:group, users: [user, second_user, third_user]) }

    it 'removes a member of a group' do
      UserGroup.set_is_admin(group.id, user.id, true)
      admins_of_group = UserGroup.where(group_id: group.id, is_admin: true)
      expect { put :remove_group_member, params: {id: group.id, removing_member: user.id} }.to change { group.users.count }.by(-1)
      expect(admins_of_group).to eq(UserGroup.where(group_id: group.id, is_admin: true))
    end

    context 'without authorization' do
      context 'user is not in group' do
        before { put :remove_group_member, params: {id: group_without_user.id, removing_member: user.id} }
        it 'redirects to groups page' do
          expect(response).to redirect_to(groups_path)
        end

        it 'shows an alert message' do
          expect(flash[:alert]).to eq I18n.t('unauthorized.edit.group')
        end
      end

      context 'user is group member but not admin' do
        before { put :remove_group_member, params: {id: group.id, removing_member: user.id} }
        it 'redirects to groups page' do
          expect(response).to redirect_to(groups_path)
        end

        it 'shows an alert message' do
          expect(flash[:alert]).to eq I18n.t('unauthorized.edit.group')
        end
      end
    end
  end

  describe 'POST condition for changing member status' do
    let(:user) { FactoryBot.create(:user) }
    let(:second_user) { FactoryBot.create(:user) }
    let(:third_user) { FactoryBot.create(:user) }
    let(:group) { FactoryBot.create(:group, users: [user, second_user, third_user]) }
    let(:second_group) { FactoryBot.create(:group, users: [user]) }
    let(:json) { JSON.parse(response.body) }

    render_views

    it "returns 'last_admin' if the member is the last admin (but there are still other members)" do
      UserGroup.set_is_admin(group.id, user.id, true)
      post :condition_for_changing_member_status, params: {format: :json, id: group.id, changing_member: user.id}
      expect(json).to have_content('last_admin')
    end

    it "returns 'last_member' if the member is the last member" do
      UserGroup.set_is_admin(second_group.id, user.id, true)
      post :condition_for_changing_member_status, params: {format: :json, id: second_group.id, changing_member: user.id}
      expect(json).to have_content('last_member')
    end

    it "returns 'ok' if there are no restrictions to remove the member" do
      UserGroup.set_is_admin(group.id, user.id, true)
      post :condition_for_changing_member_status, params: {format: :json, id: group.id, changing_member: second_user.id}
      expect(json).to have_content('ok')
    end
  end

  describe 'POST all members to administrators' do
    let(:user) { FactoryBot.create(:user) }
    let(:second_user) { FactoryBot.create(:user) }
    let(:third_user) { FactoryBot.create(:user) }
    let(:group) { FactoryBot.create(:group, users: [user, second_user, third_user]) }

    it 'makes all members of a group to admins' do
      UserGroup.set_is_admin(group.id, user.id, true)
      put :all_members_to_administrators, params: {id: group.id}
      current_admins_of_group = UserGroup.where(group_id: group.id, is_admin: true)
      expect(current_admins_of_group.count).to eq(group.users.count)
    end

    context 'without authorization' do
      context 'user is not in group' do
        before { put :all_members_to_administrators, params: {id: group_without_user.id} }
        it 'redirects to groups page' do
          expect(response).to redirect_to(groups_path)
        end

        it 'shows an alert message' do
          expect(flash[:alert]).to eq I18n.t('unauthorized.edit.group')
        end
      end

      context 'user is group member but not admin' do
        before { put :all_members_to_administrators, params: {id: group.id} }
        it 'redirects to groups page' do
          expect(response).to redirect_to(groups_path)
        end

        it 'shows an alert message' do
          expect(flash[:alert]).to eq I18n.t('unauthorized.edit.group')
        end
      end
    end
  end

  describe 'GET members' do
    render_views
    let(:json) { JSON.parse(response.body) }

    let(:user) { FactoryBot.create(:user) }
    let(:second_user) { FactoryBot.create(:user) }
    let(:group) { FactoryBot.create(:group, users: [user, second_user]) }

    it 'returns JSON with all members exclude the current user' do
      get :members, params: {format: :json, id: group.id}
      expect(json).to have_content(second_user.id)
      expect(json).not_to have_content(user.id)
    end

    context 'without authorization' do
      context 'user is not in group' do
        before { get :members, params: {id: group_without_user.id} }
        it 'redirects to groups page' do
          expect(response).to redirect_to(groups_path)
        end

        it 'shows an alert message' do
          expect(flash[:alert]).to eq I18n.t('unauthorized.show.group')
        end
      end
    end
  end

  describe 'GET groups_where_user_is_admin' do
    render_views
    let(:json) { JSON.parse(response.body) }
    let!(:second_group_with_admin) do
      second_group_with_admin = FactoryBot.create(:group, users: [user], name: 'A')
      UserGroup.set_is_admin(second_group_with_admin.id, user.id, true)
      second_group_with_admin
    end

    it 'returns all groups where current_user is admin' do
      get :groups_where_user_is_admin, params: {format: :json}
      expect(json).to have_content group_with_admin.name
      expect(json).to have_content group_with_admin.id
      expect(json).to have_content second_group_with_admin.name
      expect(json).to have_content second_group_with_admin.id
      expect(json).not_to have_content group.name
      expect(json).not_to have_content group.id
    end

    it 'sorts the result' do
      get :groups_where_user_is_admin, params: {format: :json}
      expected_json = [{'id' => second_group_with_admin.id, 'name' => second_group_with_admin.name}, {'id' => group_with_admin.id, 'name' => group_with_admin.name}]
      expect(json).to eq expected_json
    end
  end
end
