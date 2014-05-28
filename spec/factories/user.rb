require 'factory_girl'

FactoryGirl.define do
  factory :user do
    sequence(:username) { |n| "user_#{n}" }
    agreed_to_terms_of_service true

    factory :admin do
      roles { [Role.where(name: 'admin').first_or_create] }
    end
  end
end
