require 'rails_helper'

RSpec.describe 'user_dates/index', type: :view do
  before(:each) do
    assign(:user_dates, [
      UserDate.create!(
        user: nil,
        course: nil,
        mooc_provider: nil,
        title: 'Title',
        kind: 'Kind',
        relevant: false,
        ressource_id_from_provider: 'Ressource Id From Provider'
      ),
      UserDate.create!(
        user: nil,
        course: nil,
        mooc_provider: nil,
        title: 'Title',
        kind: 'Kind',
        relevant: false,
        ressource_id_from_provider: 'Ressource Id From Provider'
      )
    ])
  end

  it 'renders a list of user_dates' do
    render
    assert_select 'tr>td', text: nil.to_s, count: 2
    assert_select 'tr>td', text: nil.to_s, count: 2
    assert_select 'tr>td', text: nil.to_s, count: 2
    assert_select 'tr>td', text: 'Title'.to_s, count: 2
    assert_select 'tr>td', text: 'Kind'.to_s, count: 2
    assert_select 'tr>td', text: false.to_s, count: 2
    assert_select 'tr>td', text: 'Ressource Id From Provider'.to_s, count: 2
  end
end
