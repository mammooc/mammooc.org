# encoding: utf-8
# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'groups/new', type: :view do
  before(:each) do
    assign(:group, Group.new(
                     name: 'MyString',
                     description: 'MyText'
    ))
  end

  it 'renders new group form' do
    render

    assert_select 'form[action=?][method=?]'.dup, groups_path, 'post' do
      assert_select 'input#group_name[name=?]'.dup, 'group[name]'

      assert_select 'textarea#group_description[name=?]'.dup, 'group[description]'
    end
  end
end
