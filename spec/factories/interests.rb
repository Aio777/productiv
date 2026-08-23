
# == Schema Information
#
# Table name: interests
#
#  id         :bigint           not null, primary key
#  email      :string
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
FactoryBot.define do
  factory :interest do |n|
    name { "Test User" }
    sequence(:email) { |n| "test#{n}@example.com" }
  end
end
