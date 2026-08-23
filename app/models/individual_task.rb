# frozen_string_literal: true

# == Schema Information
#
# Table name: individual_tasks
#
#  id                    :bigint           not null, primary key
#  description           :string
#  difficulty            :string
#  due_date              :datetime         not null
#  name                  :string
#  points                :integer
#  read                  :boolean
#  reminder_date         :datetime
#  status_complete       :boolean          default(FALSE), not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  individual_project_id :bigint           not null
#
# Indexes
#
#  index_individual_tasks_on_individual_project_id  (individual_project_id)
#
# Foreign Keys
#
#  fk_rails_...  (individual_project_id => individual_projects.id)
#
class IndividualTask < ApplicationRecord
  validates :name, presence: true
  validates :due_date, presence: true
  validates :reminder_date, presence: true, allow_nil: true
  validates :description, presence: true, allow_nil: true
  validates :difficulty, inclusion: { in: %w[easy medium hard], message: '%<value> is not a valid difficulty' },
                         allow_nil: true
  validates :points, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: false

  belongs_to :individual_project

  has_one :notification, dependent: :destroy

  def overdue?
    due_date && due_date < Time.current
  end
end
