require 'rails_helper'

RSpec.describe ActivitiesController, type: :controller do

  describe 'delete group newsfeed_entry' do
    let!(:group) {FactoryGirl.create(:group)}
    let!(:group2) {FactoryGirl.create(:group)}

    it 'destroys the requested newsfeed_entry of specified group' do
      request.env['HTTP_REFERER'] = dashboard_path
      activity = FactoryGirl.create(:activity, group_ids: [group.id], user_ids: nil)
      expect do
        get :delete_group_from_newsfeed_entry, id: activity.id, group_id: group.id
      end.to change(PublicActivity::Activity, :count).by(-1)
    end

    it 'removes the specified group from activity' do
      request.env['HTTP_REFERER'] = dashboard_path
      activity = FactoryGirl.create(:activity, group_ids: [group.id, group2.id], user_ids: nil)
      expect do
        get :delete_group_from_newsfeed_entry, id: activity.id, group_id: group.id
      end.to change(activity.group_ids, :count).by(-1)
    end
  end

end
