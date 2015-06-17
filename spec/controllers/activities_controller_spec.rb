require 'rails_helper'

RSpec.describe ActivitiesController, type: :controller do

  describe 'delete group newsfeed_entry' do
    let(:group) {FactoryGirl.create(:group)}
    it 'destroys the requested newsfeed_entry of specified group' do
      request.env['HTTP_REFERER'] = dashboard_path
      activity = FactoryGirl.create(:activity, group_ids: [group.id], user_ids: nil)
      expect do
        get :delete_group_from_newsfeed_entry, id: activity.id, group_id: group.id
      end.to change(Recommendation, :count).by(-1)
    end
  end

end
