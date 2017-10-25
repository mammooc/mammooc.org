# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'users/completions', type: :view do
  let(:user) { FactoryBot.create(:user) }
  let(:course) { FactoryBot.create(:course) }
  let(:first_completion) do
    Completion.create!(
      quantile: 0.1,
      points_achieved: 84,
      provider_percentage: 97,
      user: user,
      course: course
    )
  end
  let(:completions) do
    [first_completion,
     Completion.create!(
       quantile: 0.5,
       points_achieved: 35.4,
       provider_percentage: 23.7,
       user: user,
       course: course
     )]
  end
  let(:certificates) do
    [Certificate.create!(
      title: 'Procotored Certificate',
      download_url: 'https://example.com/get_certificate',
      verification_url: nil,
      type: 'certificate',
      completion: first_completion
    ),
     Certificate.create!(
       title: nil,
       download_url: 'https://example.com/get_certificate',
       verification_url: 'https://example.com/verify',
       type: 'record_of_achievement',
       completion: first_completion
     )]
  end

  before do
    sign_in user
    assign(:completions, completions)
    assign(:user, user)
    assign(:provider_logos, {})
    assign(:number_of_certificates, [2, 0])
    assign(:verify_available, [true, false])
  end

  it 'renders a list of completions' do
    render
    assert rendered, text: I18n.t('completions.points_achieved', points_achieved: '84'), count: 1
    assert rendered, text: I18n.t('completions.points_achieved', points_achieved: '35.4'), count: 1
    assert rendered, text: '97.0 %', count: 1
    assert rendered, text: '23.7 %', count: 1
    assert rendered, text: I18n.t('completions.verify'), count: 1
    assert rendered, text: I18n.t('completions.unable_to_verify'), count: 1
    assert rendered, text: 'Procotored Certificate', count: 1
    assert rendered, text: I18n.t('completions.record_of_achievement'), count: 1
  end
end
