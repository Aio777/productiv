# frozen_string_literal: true

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
class Interest < ApplicationRecord
  validates :name,  presence: true
  validates :email, presence: true,
                    format: { with: URI::MailTo::EMAIL_REGEXP }
end
