require 'rails_helper'
require 'cancan/matchers'

RSpec.describe Ability do
  subject(:ability) { Ability.new(user) }
  let(:user) { nil }
  describe 'Groups' do
    let (:user) { FactoryGirl.create :user }
    let(:group_without_user) { FactoryGirl.create :group }
    let(:group_with_user) { FactoryGirl.create :group, users: [user] }

    it { should be_able_to(:show, group_with_user) }
    it { should_not be_able_to(:show, group_without_user) }
  end
end