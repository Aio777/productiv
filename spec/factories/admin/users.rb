# == Schema Information
#
# Table name: admin_users
#
#  id         :bigint           not null, primary key
#  body       :text
#  title      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
FactoryBot.define do
  factory :admin_user do
    first_name { "Test" }
    last_name  { "User" }
    sequence(:email) { |n| "test#{n}@example.com" }
    password { "Password123" }
    password_confirmation { "Password123" }
  end
end
