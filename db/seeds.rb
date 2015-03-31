# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

provider1 = MoocProvider.create(name: 'openHPI')
MoocProvider.create(name: 'openHPI China')
MoocProvider.create(name: 'mooc.house')
MoocProvider.create(name: 'openSAP')
MoocProvider.create(name: 'openSAP China')
MoocProvider.create(name: 'openUNE')


Course.create(name: 'Web Technologies',
              url: 'https://open.hpi.de/courses/webtech2015',
              course_instructors: ['Prof. Dr. Christoph Meinel', 'Jan Renz', 'Thomas Staubitz'],
              abstract: 'WWW, the world wide web or shortly the web - really nothing more than an information  service on the Internet – has changed our world by creating a whole new digital world that is closely intertwined with our real world, making reality what was previously unimaginable: communication across the world in seconds, watching movies on a smartphone, playing games or looking at photos with remote partners in distant continents, shopping or banking from your couch … In our online course on web technologies you will learn how it all works.',
              description: 'WWW, the world wide web or shortly the web - really nothing more than an information service on the Internet – has changed our world by creating a whole new digital world that is closely intertwined with our real world, making reality what was previously unimaginable: communication across the world in seconds, watching movies on a smartphone, playing games or looking at photos with remote partners in distant continents, shopping or banking from your couch … In our online course on web technologies you will learn how it all works.

We start off by introducing the underlying technologies of the web: URI, HTTP, HTML, CSS and XML. If this sounds cryptic, rest assured that you will soon become familiar with what it’s all about. We will then focus on web services and web programming technologies along with their practical application. And we will look at how search engines – our fast and reliable signposts in the digital world – actually work to find contents and services on the web. The course concludes with a look at cloud computing and how it is changing the way we will access computing power in the future.

Here’s what participants are saying about this course:

Ralf: “The concept is great and methodically and didactically well thought out. We all noticed that further development is continually going on here - indispensable in dealing with this topic today. The support and guidance from the help desk and forum were also outstanding. Thank you.”

Kerstin: “I have to honestly say that I am impressed by what you’ve accomplished here. The course was totally professional and the tasks were set up so that it was possible to learn a lot. It was important for me to get an overview of the technologies and relationships between them. The class was taught really well and it was fun too.”

Claudia; “I enjoyed this course so much. It gave me a chance to expand my horizons in web technologies a great deal. I really liked the practical homework exercises, especially the calculation task in Week 5. I’m already looking forward to the next course. Keep up the good work!”',
              language: 'English',
              imageId: 'https://open.hpi.de/files/45ce8877-d21b-4389-9032-c6525b4724d0',
              videoId: '',
              start_date: DateTime.new(2015,6,1,8),
              end_date: DateTime.new(2015,7,20,23,30),
              costs: 10,
              price_currency: '€',
              type_of_achievement:'Certificate',
              categories: ['Web','Technologies','Computer Science','#geilon'],
              requirements: %w[Computer Brain Strength],
              difficulty: 'medium',
              minimum_weekly_workload: 7,
              maximum_weekly_workload: 45,
              provider_course_id: 1,
              credit_points: 6,
              mooc_provider_id: provider1.id
)
Course.create(name: 'Minimal Technologies',
              url: 'https://open.hpi.de/courses/pythonjunior2015',
              start_date: DateTime.new(2015,9,3,9),
              end_date: DateTime.new(2015,10,20,22,10),
              provider_course_id: 2,
              mooc_provider_id: provider1.id
)

user1 =User.create(first_name: 'Max', last_name: 'Mustermann', email: 'max@test.com', password: '12345678')
user2 = User.create(first_name: 'Maxi', last_name: 'Musterfrau', email: 'maxi@test.com', password: '12345678')

group1 = Group.create(name: 'Testgruppe1', description: 'blablub')

20.times do |i|
  user = User.create first_name: "Maximus_#{i}",
                      last_name: "Mustermann",
                      email: "maximus_#{i}@test.com",
                      password: "12345678"
  group1.users.push user
end


group1.users.push(user1,user2)
UserGroup.set_is_admin(group1.id, user1.id, true)

group2 = Group.create(name: 'Testgruppe2', description: 'blablub')

group2.users.push(user2)
UserGroup.set_is_admin(group2.id, user2.id, true)

group3 = Group.create(name: 'Testgruppe3', description: 'blablub')

group3.users.push(user1, user2)

UserGroup.set_is_admin(group3.id, user1.id, true)
UserGroup.set_is_admin(group3.id, user2.id, true)
