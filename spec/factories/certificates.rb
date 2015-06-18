# -*- encoding : utf-8 -*-
FactoryGirl.define do
  factory :full_transcript_of_participation, class: Certificate do
    title 'Full Transcript of Participation'
    completion
    download_url 'https://www.open.hpi.de'
    verification_url 'https://www.hpi.de'
    document_type 'transcript_of_participation'
  end

  factory :full_record_of_achievement, class: Certificate do
    title 'Full Record of Achievement'
    completion
    download_url 'https://www.open.hpi.de'
    verification_url 'https://www.hpi.de'
    document_type 'record_of_achievement'
  end

  factory :full_certificate, class: Certificate do
    title 'Full Certificate'
    completion
    download_url 'https://www.open.hpi.de'
    verification_url 'https://www.hpi.de'
    document_type 'certificate'
  end

  factory :transcript_of_participation, class: Certificate do
    title nil
    completion
    download_url 'https://www.open.hpi.de'
    verification_url nil
    document_type 'transcript_of_participation'
  end

  factory :record_of_achievement, class: Certificate do
    title nil
    completion
    download_url 'https://www.open.hpi.de'
    verification_url nil
    document_type 'record_of_achievement'
  end

  factory :certificate, class: Certificate do
    title nil
    completion
    download_url 'https://www.open.hpi.de'
    verification_url nil
    document_type 'certificate'
  end
end
