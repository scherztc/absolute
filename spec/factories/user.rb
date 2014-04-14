require 'factory_girl'

FactoryGirl.define do
  factory :user do
    sequence(:email) { |n| "user_#{n}@example.com" }
    password 'password'
    agreed_to_terms_of_service true
    user_does_not_require_profile_update true

    factory :admin do
      roles { [Role.where(name: 'admin').first_or_create] }
    end
  end
end
