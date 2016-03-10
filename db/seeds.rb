# -*- encoding : utf-8 -*-
# rubocop:disable Lint/UselessAssignment

# seeds for all environments

open_hpi = MoocProvider.create!(name: 'openHPI', logo_id: 'logo_openHPI.svg', url: 'https://open.hpi.de', api_support_state: :naive)
MoocProvider.create!(name: 'openHPI China', logo_id: 'logo_openHPI.svg', url: 'https://openhpi.cn', api_support_state: :naive)
MoocProvider.create!(name: 'mooc.house', logo_id: 'logo_mooc_house.svg', url: 'https://mooc.house', api_support_state: :naive)
MoocProvider.create!(name: 'cnmooc.house', logo_id: 'logo_cnmooc_house.svg', url: 'https://cnmooc.house', api_support_state: :naive)
open_sap = MoocProvider.create!(name: 'openSAP', logo_id: 'logo_openSAP.svg', url: 'https://open.sap.com', api_support_state: :naive)
MoocProvider.create!(name: 'edX', logo_id: 'logo_edX.svg', url: 'https://www.edx.org', api_support_state: :nil)
MoocProvider.create!(name: 'coursera', logo_id: 'logo_coursera.svg', url: 'https://www.coursera.org', api_support_state: :oauth)
MoocProvider.create!(name: 'openSAP China', logo_id: 'logo_openSAP.svg', url: 'https://open.sap.cn', api_support_state: :naive)
MoocProvider.create!(name: 'openUNE', logo_id: 'logo_openUNE.svg', url: 'https://openune.cn', api_support_state: :naive)
MoocProvider.create!(name: 'iversity', logo_id: 'logo_iversity.svg', url: 'https://iversity.org', api_support_state: :nil)
MoocProvider.create!(name: 'Udacity', logo_id: 'logo_UDACITY.svg', url: 'https://www.udacity.com', api_support_state: :nil)

xikolo_audit_track_type = CourseTrackType.create!(title: 'Audit',
                                                  description: 'You get a record of Achievement.',
                                                  type_of_achievement: 'xikolo_record_of_achievement')
iversity_audit_track_type = CourseTrackType.create!(title: 'Audit',
                                                    description: "<ul class='list-none'> <li>All Course Material</li> <li>Course Community</li> <li>Statement of Participation</li> <li>Flexible Upgrade</li> </ul>",
                                                    type_of_achievement: 'iversity_record_of_achievement')
coursera_audit_track_type = CourseTrackType.create!(title: 'Audit',
                                                    description: 'You do not receive a participation document.',
                                                    type_of_achievement: 'nothing')
udacity_audit_track_type = CourseTrackType.create!(title: 'Free',
                                                   description: 'You get instructor videos and learning by doing exercises.',
                                                   type_of_achievement: 'udacity_nothing')
certificate_track_type = CourseTrackType.create!(title: 'Certificate',
                                                 description: 'You get a certificate.',
                                                 type_of_achievement: 'certificate')
iversity_certificate_track_type = CourseTrackType.create!(title: 'Certificate',
                                                          description: "<ul class='list-none'> <li>Course Community</li> <li>Graded Online Exam</li> <li>Graded Online Exam</li> <li>Certificate Supplement</li> </ul>",
                                                          type_of_achievement: 'iversity_certificate')
edx_certificate_track_type = CourseTrackType.create!(title: 'Verified Certificate',
                                                     description: 'Receive a credential signed by the instructor, with the institution logo to verify your achievement and increase your job prospects.',
                                                     type_of_achievement: 'edx_verified_certificate')
udacity_certificate_track_type = CourseTrackType.create!(title: 'Full Course',
                                                         description: 'You get instructor videos, learning by doing exercises, help from coaches and a verified certificate',
                                                         type_of_achievement: 'udacity_verified_certificate')
iversity_ects_track_type = CourseTrackType.create!(title: 'ECTS',
                                                   description: "<ul class='list-none'> <li>Graded Course Project</li> <li>Certificate of Accomplishment</li> <li>Certificate Supplement</li> <li>3 ECTS-Points</li> </ul>",
                                                   type_of_achievement: 'iversity_ects')
signature_track_type = CourseTrackType.create!(title: 'Signature Track',
                                               description: 'You get a Verified Certificate issued by Coursera and the participating university.',
                                               type_of_achievement: 'coursera_verified_certificate')
edx_xseries_track_type = CourseTrackType.create!(title: 'XSeries',
                                                 description: 'You get an edX XSeries certificate.',
                                                 type_of_achievement: 'edx_xseries_verified_certificate')
edx_profed_track_type = CourseTrackType.create!(title: 'Professional Education',
                                                description: 'You get a Professional Education certificate.',
                                                type_of_achievement: 'edx_profed_certificate')
iversity_student_track = CourseTrackType.create!(title: 'Schüler-Track',
                                                 description: "<ul class=\"list-none\">\r\n<li>Benotete Präsenzprüfung</li>\r\n<li>Leistungsnachweis</li>\r\n<li>Zertifikatszusatz</li>\r\n<li>5 ECTS-Punkte</li>\r\n</ul>\r\n",
                                                 type_of_achievement: 'iversity_ects_pupils')

OpenHPICourseWorker.perform_async
OpenSAPCourseWorker.perform_async
OpenHPIChinaCourseWorker.perform_async
OpenSAPChinaCourseWorker.perform_async
MoocHouseCourseWorker.perform_async
CnmoocHouseCourseWorker.perform_async
OpenUNECourseWorker.perform_async
EdxCourseWorker.perform_async
CourseraCourseWorker.perform_async
IversityCourseWorker.perform_async
UdacityCourseWorker.perform_async

# specific seeds for different environments

case Rails.env
  when 'development'
    open_mammooc = MoocProvider.create!(name: 'open_mammooc', logo_id: 'logo_open_mammooc.png', url: 'https://example.com', api_support_state: :nil)

    minimal_previous_course = Course.create!(name: 'Minimal Previous Technologies',
                                             url: 'https://open.hpi.de/courses/pythonjunior2015',
                                             provider_course_id: 2,
                                             mooc_provider_id: open_mammooc.id,
                                             tracks: [CourseTrack.create!(track_type: xikolo_audit_track_type)]
                                            )

    minimal_following_course = Course.create!(name: 'Minimal Following Technologies',
                                              url: 'https://open.hpi.de/courses/pythonjunior2015',
                                              provider_course_id: 3,
                                              mooc_provider_id: open_mammooc.id,
                                              tracks: [CourseTrack.create!(track_type: xikolo_audit_track_type)]
                                             )

    full_course = Course.create!(name: 'Web Technologies',
                                 url: 'https://open.hpi.de/courses/webtech2015',
                                 course_instructors: 'Prof. Dr. Christoph Meinel, Jan Renz',
                                 abstract: 'WWW, the world wide web or shortly the web - really nothing more than an information  service on the Internet – has changed our world by creating a whole new digital world that is closely intertwined with our real world, making reality what was previously unimaginable: communication across the world in seconds, watching movies on a smartphone, playing games or looking at photos with remote partners in distant continents, shopping or banking from your couch … In our online course on web technologies you will learn how it all works.',
                                 description: 'WWW, the world wide web or shortly the web - really nothing more than an information service on the Internet – has changed our world by creating a whole new digital world that is closely intertwined with our real world, making reality what was previously unimaginable: communication across the world in seconds, watching movies on a smartphone, playing games or looking at photos with remote partners in distant continents, shopping or banking from your couch … In our online course on web technologies you will learn how it all works.

    We start off by introducing the underlying technologies of the web: URI, HTTP, HTML, CSS and XML. If this sounds cryptic, rest assured that you will soon become familiar with what it’s all about. We will then focus on web services and web programming technologies along with their practical application. And we will look at how search engines – our fast and reliable signposts in the digital world – actually work to find contents and services on the web. The course concludes with a look at cloud computing and how it is changing the way we will access computing power in the future.

    Here’s what participants are saying about this course:

    Ralf: “The concept is great and methodically and didactically well thought out. We all noticed that further development is continually going on here - indispensable in dealing with this topic today. The support and guidance from the help desk and forum were also outstanding. Thank you.”

    Kerstin: “I have to honestly say that I am impressed by what you’ve accomplished here. The course was totally professional and the tasks were set up so that it was possible to learn a lot. It was important for me to get an overview of the technologies and relationships between them. The class was taught really well and it was fun too.”

    Claudia; “I enjoyed this course so much. It gave me a chance to expand my horizons in web technologies a great deal. I really liked the practical homework exercises, especially the calculation task in Week 5. I’m already looking forward to the next course. Keep up the good work!”',
                                 language: 'en,de',
                                 subtitle_languages: 'en,de',
                                 videoId: '',
                                 start_date: Time.zone.local(2015, 6, 1, 8),
                                 end_date: Time.zone.local(2015, 7, 20, 23, 30),
                                 provider_given_duration: '8 weeks',
                                 categories: ['Web', 'Technologies', 'Computer Science', '#geilon'],
                                 requirements: %w(Computer Brain Strength),
                                 difficulty: 'medium',
                                 workload: '4-6 hours per week',
                                 provider_course_id: 1,
                                 mooc_provider_id: open_mammooc.id,
                                 previous_iteration_id: minimal_previous_course.id,
                                 following_iteration_id: minimal_following_course.id,
                                 tracks: [CourseTrack.create!(track_type: xikolo_audit_track_type),
                                          CourseTrack.create!(track_type: certificate_track_type, costs: 20.0, costs_currency: '€'),
                                          CourseTrack.create!(track_type: iversity_ects_track_type, costs: 50.0, costs_currency: '€')],
                                 points_maximal: 105.7
                                )

    user1 = User.create!(first_name: 'Max', last_name: 'Mustermann', primary_email: 'max@example.com', password: '12345678')
    user2 = User.create!(first_name: 'Maxi', last_name: 'Musterfrau', primary_email: 'maxi@example.com', password: '12345678')

    Evaluation.create!(user_id: user1.id, course_id: full_course.id, rating: 5, description: 'Super Kurs!', course_status: :finished, rated_anonymously: false, total_feedback_count: 101, positive_feedback_count: 101)
    Evaluation.create!(user_id: user2.id, course_id: full_course.id, rating: 2, course_status: :aborted, rated_anonymously: true)

    group1 = Group.create!(name: 'Testgruppe1', description: 'Testgruppe1 ist die Beste!')

    20.times do |i|
      user = User.create! first_name: "Maximus_#{i}",
                          last_name: 'Mustermann',
                          primary_email: "maximus_#{i}@example.com",
                          password: '12345678'
      group1.users.push user
    end

    group1.users.push(user1, user2)
    UserGroup.set_is_admin(group1.id, user1.id, true)

    group2 = Group.create!(name: 'Testgruppe2', description: 'Testgruppe2 ist auch gut!')

    group2.users.push(user2)
    UserGroup.set_is_admin(group2.id, user2.id, true)

    group3 = Group.create!(name: 'Testgruppe3', description: 'Testgruppe3 ist eine Enttäuschung...')

    group3.users.push(user1, user2)

    UserGroup.set_is_admin(group3.id, user1.id, true)
    UserGroup.set_is_admin(group3.id, user2.id, true)

    user1.setting(:course_enrollments_visibility, true).set(:groups, [group1.id, group2.id])
    user1.setting(:course_enrollments_visibility, true).set(:users, [user2.id])
    user1.setting(:course_results_visibility, true).set(:groups, [group1.id, group2.id])
    user1.setting(:course_results_visibility, true).set(:users, [user2.id])
    user1.setting(:course_progress_visibility, true).set(:groups, [group1.id, group2.id])
    user1.setting(:course_progress_visibility, true).set(:users, [user2.id])
    user1.setting(:profile_visibility, true).set(:groups, [group1.id, group2.id])
    user1.setting(:profile_visibility, true).set(:users, [user2.id])

    4.times { FactoryGirl.create(:group_recommendation, course: full_course, group: group1, users: group1.users) }
    3.times { FactoryGirl.create(:user_recommendation, course: full_course, users: [user1]) }
    2.times { FactoryGirl.create(:user_recommendation, course: full_course, users: [user2]) }

    FactoryGirl.create(:group_recommendation, course: full_course, group: group1, users: group1.users, author: user2)
    FactoryGirl.create(:user_recommendation, course: full_course, users: [user1], author: user2)

    if ENV['OPEN_HPI_TOKEN'].present?
      FactoryGirl.create(:naive_mooc_provider_user, user: user1, mooc_provider: open_hpi, access_token: ENV['OPEN_HPI_TOKEN'])
    end

    if ENV['OPEN_SAP_TOKEN'].present?
      FactoryGirl.create(:naive_mooc_provider_user, user: user1, mooc_provider: open_sap, access_token: ENV['OPEN_SAP_TOKEN'])
    end

    FactoryGirl.create(:full_completion, course: full_course, user: user1)
    completion1 = FactoryGirl.create(:completion, course: minimal_following_course, user: user1)
    FactoryGirl.create(:confirmation_of_participation, completion: completion1)
    FactoryGirl.create(:record_of_achievement, completion: completion1, verification_url: 'https://mammooc.org', title: 'open_mammooc Achievement')
    completion2 = FactoryGirl.create(:completion, course: minimal_previous_course, user: user1, points_achieved: 24.0)
    FactoryGirl.create(:confirmation_of_participation, completion: completion2)
    FactoryGirl.create(:full_completion, course: minimal_previous_course, user: user2)

end

# rubocop:enable Lint/UselessAssignment
