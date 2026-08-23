# frozen_string_literal: true

# == Schema Information
#
# Table name: items
#
#  id          :bigint           not null, primary key
#  category    :string
#  description :string
#  image_url   :string
#  name        :string
#  price       :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class Item < ApplicationRecord
  has_many :user_items, dependent: :destroy
  has_many :users, through: :user_items

  def owned_by?(user)
    UserItem.where(item: self, user: user).exists?
  end
end
