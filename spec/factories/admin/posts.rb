# == Schema Information
#
# Table name: admin_posts
#
#  id         :bigint           not null, primary key
#  body       :text
#  title      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
FactoryBot.define do
  factory :admin_post, class: 'Admin::Post' do
    title { "MyString" }
    body { "MyText" }
  end
end
