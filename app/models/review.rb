# frozen_string_literal: true

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
class Review < ApplicationRecord
  validates :name, presence: true
  validates :rating, numericality: { only_integer: true }
  validates :body, presence: true
end
