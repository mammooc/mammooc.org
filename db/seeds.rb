# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

provider1 = MoocProvider.create(name: 'testProvider', logo_id: 'logo_openHPI.png')
openHPI = MoocProvider.create(name: 'openHPI', logo_id: 'logo_openHPI.png')
MoocProvider.create(name: 'openHPI China', logo_id: 'logo_openHPI.png')
MoocProvider.create(name: 'mooc.house', logo_id: 'logo_mooc_house.png')
openSAP = MoocProvider.create(name: 'openSAP', logo_id: 'logo_openSAP.png')
MoocProvider.create(name: 'edX', logo_id: 'logo_edx.png')
MoocProvider.create(name: 'coursera', logo_id: 'logo_coursera.png')
MoocProvider.create(name: 'openSAP China', logo_id: 'logo_openSAP.png')
MoocProvider.create(name: 'openUNE', logo_id: 'logo_openUNE.png')

minimal_previous_course = Course.create(name: 'Minimal Previous Technologies',
              url: 'https://open.hpi.de/courses/pythonjunior2015',
              provider_course_id: 2,
              mooc_provider_id: provider1.id,
              has_free_version: true

)

minimal_following_course = Course.create(name: 'Minimal Following Technologies',
                                        url: 'https://open.hpi.de/courses/pythonjunior2015',
                                        provider_course_id: 2,
                                        mooc_provider_id: provider1.id,
                                        has_paid_version: true
)

full_course = Course.create(name: 'Web Technologies',
              url: 'https://open.hpi.de/courses/webtech2015',
              course_instructors: 'Prof. Dr. Christoph Meinel, Jan Renz',
              abstract: 'WWW, the world wide web or shortly the web - really nothing more than an information  service on the Internet – has changed our world by creating a whole new digital world that is closely intertwined with our real world, making reality what was previously unimaginable: communication across the world in seconds, watching movies on a smartphone, playing games or looking at photos with remote partners in distant continents, shopping or banking from your couch … In our online course on web technologies you will learn how it all works.',
              description: 'WWW, the world wide web or shortly the web - really nothing more than an information service on the Internet – has changed our world by creating a whole new digital world that is closely intertwined with our real world, making reality what was previously unimaginable: communication across the world in seconds, watching movies on a smartphone, playing games or looking at photos with remote partners in distant continents, shopping or banking from your couch … In our online course on web technologies you will learn how it all works.

We start off by introducing the underlying technologies of the web: URI, HTTP, HTML, CSS and XML. If this sounds cryptic, rest assured that you will soon become familiar with what it’s all about. We will then focus on web services and web programming technologies along with their practical application. And we will look at how search engines – our fast and reliable signposts in the digital world – actually work to find contents and services on the web. The course concludes with a look at cloud computing and how it is changing the way we will access computing power in the future.

Here’s what participants are saying about this course:

Ralf: “The concept is great and methodically and didactically well thought out. We all noticed that further development is continually going on here - indispensable in dealing with this topic today. The support and guidance from the help desk and forum were also outstanding. Thank you.”

Kerstin: “I have to honestly say that I am impressed by what you’ve accomplished here. The course was totally professional and the tasks were set up so that it was possible to learn a lot. It was important for me to get an overview of the technologies and relationships between them. The class was taught really well and it was fun too.”

Claudia; “I enjoyed this course so much. It gave me a chance to expand my horizons in web technologies a great deal. I really liked the practical homework exercises, especially the calculation task in Week 5. I’m already looking forward to the next course. Keep up the good work!”',
              language: 'English',
              subtitle_languages: 'English, German',
              imageId: 'https://open.hpi.de/files/45ce8877-d21b-4389-9032-c6525b4724d0',
              videoId: '',
              start_date: DateTime.new(2015,6,1,8),
              end_date: DateTime.new(2015,7,20,23,30),
              provider_given_duration: '8 weeks',
              costs: 10,
              price_currency: '€',
              type_of_achievement:'Certificate',
              categories: ['Web','Technologies','Computer Science','#geilon'],
              requirements: %w[Computer Brain Strength],
              difficulty: 'medium',
              workload: '4-6 hours per week',
              provider_course_id: 1,
              credit_points: 6,
              mooc_provider_id: provider1.id,
              previous_iteration_id: minimal_previous_course.id,
              following_iteration_id: minimal_following_course.id,
              has_paid_version: true,
              has_free_version: true
)


user1 = User.create(first_name: 'Max', last_name: 'Mustermann', email: 'max@example.com', password: '12345678', profile_image_id: 'profile_picture_default.png')
user2 = User.create(first_name: 'Maxi', last_name: 'Musterfrau', email: 'maxi@example.com', password: '12345678', profile_image_id: 'profile_picture_default.png')

group1 = Group.create(name: 'Testgruppe1', description: 'Testgruppe1 ist die Beste!', image_id: 'group_picture_default.png')

20.times do |i|
  user = User.create first_name: "Maximus_#{i}",
                      last_name: "Mustermann",
                      email: "maximus_#{i}@example.com",
                      password: "12345678",
                      profile_image_id: 'profile_picture_default.png'
  group1.users.push user
end


group1.users.push(user1,user2)
UserGroup.set_is_admin(group1.id, user1.id, true)

group2 = Group.create(name: 'Testgruppe2', description: 'Testgruppe2 ist auch gut!', image_id: 'group_picture_default.png')

group2.users.push(user2)
UserGroup.set_is_admin(group2.id, user2.id, true)

group3 = Group.create(name: 'Testgruppe3', description: 'Testgruppe3 ist eine Enttäuschung...', image_id: 'group_picture_default.png')

group3.users.push(user1, user2)

UserGroup.set_is_admin(group3.id, user1.id, true)
UserGroup.set_is_admin(group3.id, user2.id, true)

4.times do FactoryGirl.create(:group_recommendation, course: full_course, group: group1, users: group1.users) end
3.times do FactoryGirl.create(:user_recommendation, course: full_course, users: [user1]) end
2.times do FactoryGirl.create(:user_recommendation, course: full_course, users: [user2]) end

OpenHPICourseWorker.perform_async
OpenSAPCourseWorker.perform_async
EdxCourseWorker.perform_async
CourseraCourseWorker.perform_async

if ENV['OPEN_HPI_TOKEN'].present?
  FactoryGirl.create(:mooc_provider_user, user: user1, mooc_provider: openHPI, authentication_token: ENV['OPEN_HPI_TOKEN'])
end

if ENV['OPEN_SAP_TOKEN'].present?
  FactoryGirl.create(:mooc_provider_user, user: user1, mooc_provider: openSAP, authentication_token: ENV['OPEN_SAP_TOKEN'])
end
