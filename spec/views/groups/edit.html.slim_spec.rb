# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'groups/edit', type: :view do
  let!(:group) do
    assign(:group, Group.create!(
                     name: 'MyString',
                     description: 'MyText'
    ))
  end

  it 'renders the edit group form' do
    render

    assert_select 'form[action=?][method=?]', group_path(group), 'post' do
      assert_select 'input#group_name[name=?]', 'group[name]'

      assert_select 'textarea#group_description[name=?]', 'group[description]'
    end
  end
end
