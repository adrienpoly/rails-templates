# frozen_string_literal: true

FactoryGirl.define do
  sequence :email do |n|
    "person#{n}@example.com"
  end

  factory :user do
    email
    password '12345678'
    password_confirmation '12345678'
    factory :admin do
      admin true
    end
  end
end
