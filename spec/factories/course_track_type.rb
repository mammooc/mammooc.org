FactoryGirl.define do

  factory :course_track_type do
    title 'Audit'
    description 'You get a Record of Achievement.'
    type_of_achievement 'record_of_achievement'

    factory :certificate_course_track_type do
      title 'Certificate'
      description 'You get a certificate.'
      type_of_achievement 'certificate'
    end

    factory :ects_course_track_type do
      title 'ECTS'
      description 'You get ECTS points.'
      type_of_achievement 'ects'
    end
  end
end
