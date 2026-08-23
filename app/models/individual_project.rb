# frozen_string_literal: true

# == Schema Information
#
# Table name: individual_projects
#
#  id         :bigint           not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_individual_projects_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class IndividualProject < ApplicationRecord
  belongs_to :user
  has_many :individual_tasks, dependent: :destroy
end
