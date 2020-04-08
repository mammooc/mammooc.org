# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'groups/members', type: :view do
  let(:group) { FactoryBot.create(:group, users: [user, second_user, third_user]) }
  let(:user) { FactoryBot.create(:user) }
  let(:second_user) { FactoryBot.create(:user) }
  let(:third_user) { FactoryBot.create(:user) }

  before do
    @group = group

    UserGroup.set_is_admin(group.id, user.id, true)

    sign_in user

    @sorted_group_users = group.users - [user]
    @sorted_group_admins = [user]

    @profile_pictures = {}
    @group_picture = {}
  end

  it 'show all members of group' do
    render
    group.users.each do |user|
      expect(rendered).to have_content user.full_name
    end
  end
end
