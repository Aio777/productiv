# == Schema Information
#
# Table name: reviews
#
#  id                      :bigint           not null, primary key
#  body                    :text
#  hidden                  :boolean          default(FALSE)
#  name                    :string
#  negative_interest_count :integer          default(0)
#  positive_interest_count :integer          default(0)
#  rating                  :integer
#  review_index            :integer
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#
FactoryBot.define do
  factory :review do
    rating { rand(1..5) }
    body { "test body" }
    name { "test user" }
  end
end
