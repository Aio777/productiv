# == Schema Information
#
# Table name: admin_reviews
#
#  id         :bigint           not null, primary key
#  body       :text
#  title      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
FactoryBot.define do
  factory :admin_review, class: 'Admin::Review' do
    title { "MyString" }
    body { "MyText" }
  end
end
