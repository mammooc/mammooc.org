# -*- encoding : utf-8 -*-
FactoryGirl.define do
  factory :course_track_type do
    title 'Audit'
    description 'You get a Record of Achievement.'
    type_of_achievement 'openhpi_record_of_achievement'
  end

  factory :certificate_course_track_type, class: CourseTrackType do
    title 'Certificate'
    description 'You get a certificate.'
    type_of_achievement 'certificate'
  end

  factory :ects_course_track_type, class: CourseTrackType do
    title 'ECTS'
    description 'You get ECTS points.'
    type_of_achievement 'iversity_ects'
  end

  factory :signature_course_track_type, class: CourseTrackType do
    title 'Signature Track'
    description 'You get a Verified Certificate issued by Coursera and the participating university.'
    type_of_achievement 'coursera_verified_certificate'
  end
end
