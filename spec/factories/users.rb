# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  current_sign_in_at     :datetime
#  current_sign_in_ip     :string
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  failed_attempts        :integer          default(0), not null
#  first_name             :string           default("")
#  invitation_accepted_at :datetime
#  invitation_created_at  :datetime
#  invitation_limit       :integer
#  invitation_sent_at     :datetime
#  invitation_token       :string
#  invited_by_type        :string
#  last_name              :string           default("")
#  last_sign_in_at        :datetime
#  last_sign_in_ip        :string
#  layout                 :integer
#  locked_at              :datetime
#  points                 :integer          default(0), not null
#  registration_ip        :string
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  role                   :string           default("subscriber")
#  sign_in_count          :integer          default(0), not null
#  unlock_token           :string
#  was_subscriber         :boolean          default(TRUE), not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  invited_by_id          :integer
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_invitation_token      (invitation_token) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#
FactoryBot.define do
  factory :user do
    first_name { "Test" }
    last_name  { "User" }

    sequence(:email) { |n| "test#{n}@example.com" }

    password { "Password@1234" }
    password_confirmation { "Password@1234" }

    was_subscriber { role == "subscriber" }
  end
end
