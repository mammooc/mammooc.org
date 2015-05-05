# -*- encoding : utf-8 -*-
require 'rails_helper'

RSpec.describe 'statistics/edit', type: :view do
  let(:statistic) do
    assign(:statistic, Statistic.create!(
                         name: 'MyString',
                         result: 'MyText',
                         group: nil
    ))
  end

  it 'renders the edit statistic form' do
    pending
    render

    assert_select 'form[action=?][method=?]', statistic_path(statistic), 'post' do
      assert_select 'input#statistic_name[name=?]', 'statistic[name]'

      assert_select 'textarea#statistic_result[name=?]', 'statistic[result]'

      assert_select 'input#statistic_group_id[name=?]', 'statistic[group_id]'
    end
  end
end
