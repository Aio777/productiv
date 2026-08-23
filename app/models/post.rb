# frozen_string_literal: true

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
class Post < ApplicationRecord
  belongs_to :parent, class_name: 'Post', foreign_key: 'parent_id', optional: true
  has_many :replies, class_name: 'Post', foreign_key: 'parent_id', dependent: :destroy
  validates :title, presence: true
  validates :body, presence: true
end
