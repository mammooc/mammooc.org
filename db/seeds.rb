# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

#create users
user1 =User.create(first_name: 'Max', last_name: 'Mustermann', email: 'max@test.com', password: '12345678')

user2 = User.create(first_name: 'Maxi', last_name: 'Musterfrau', email: 'maxi@test.com', password: '12345678')

#create groups
group1 = Group.create(name: 'Testgruppe1', description: 'blablub')

group1.users.push(user1)
UserGroup.set_is_admin(group1.id, user1.id, true)

group2 = Group.create(name: 'Testgruppe2', description: 'blablub')

group2.users.push(user2)
UserGroup.set_is_admin(group2.id, user2.id, true)

group3 = Group.create(name: 'Testgruppe3', description: 'blablub')

group3.users.push(user1, user2)

UserGroup.set_is_admin(group3.id, user1.id, true)
UserGroup.set_is_admin(group3.id, user2.id, true)
