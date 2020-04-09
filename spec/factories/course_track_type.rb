# frozen_string_literal: true

FactoryBot.define do
  factory :course_track_type do
    title { 'Audit' }
    description { 'You get a Record of Achievement.' }
    type_of_achievement { 'xikolo_record_of_achievement' }
  end

  factory :certificate_course_track_type, class: 'CourseTrackType' do
    title { 'Certificate' }
    description { 'You get a certificate.' }
    type_of_achievement { 'certificate' }
  end

  factory :ects_course_track_type, class: 'CourseTrackType' do
    title { 'ECTS' }
    description { 'You get ECTS points.' }
    type_of_achievement { 'iversity_ects' }
  end

  factory :ects_pupils_track_type, class: 'CourseTrackType' do
    title { 'Schüler-Track' }
    description { 'You get ECTS points.' }
    type_of_achievement { 'iversity_ects_pupils' }
  end

  factory :iversity_statement_track_type, class: 'CourseTrackType' do
    title { 'Statement of Participation' }
    description { 'You get a Statement of Participation.' }
    type_of_achievement { 'iversity_statement_of_participation' }
  end

  factory :signature_course_track_type, class: 'CourseTrackType' do
    title { 'Signature Track' }
    description { 'You get a Verified Certificate issued by Coursera and the participating university.' }
    type_of_achievement { 'coursera_verified_certificate' }
  end

  factory :mooin_non_free_track_type, class: 'CourseTrackType' do
    title { 'Full Course' }
    description { 'You get a certificate from mooin.' }
    type_of_achievement { 'mooin_full_certificate' }
  end

  factory :mooin_free_track_type, class: 'CourseTrackType' do
    title { 'Free Course' }
    description { 'You get a certificate from mooin.' }
    type_of_achievement { 'mooin_certificate' }
  end
end
