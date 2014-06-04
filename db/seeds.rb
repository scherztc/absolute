# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
puts "Seeding Roles:"
roles = ["admin"]

roles.each do | name |
  puts "  #{name}"
  Role.first_or_create(name: name)
end

puts "Seeding Batch User:"
User.first_or_create(username: User.batchuser_key)

