# == Schema Information
#
# Table name: posts
#
#  id              :bigint           not null, primary key
#  answer_by_admin :boolean          default(FALSE)
#  body            :text
#  hidden          :boolean          default(FALSE)
#  interest_count  :integer          default(0)
#  title           :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  parent_id       :bigint
#
# Indexes
#
#  index_posts_on_parent_id  (parent_id)
#
# Foreign Keys
#
#  fk_rails_...  (parent_id => posts.id)
#
FactoryBot.define do
  factory :post do
    title { "Test Title" }
    body { "Test Body" }
    answer_by_admin { false }
    hidden { false }
    interest_count { 0 }
  end
end
