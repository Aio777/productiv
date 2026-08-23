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
require 'rails_helper'

RSpec.describe IndividualTask, type: :model do
  describe '#overdue?' do
    let(:user) { FactoryBot.create(:user, role: 'subscriber') }
    let(:project) { FactoryBot.create(:individual_project, user: user) }

    context 'when the due date is in the past' do
      let(:task) { FactoryBot.build(:individual_task, due_date: 1.day.ago, individual_project: project) }

      it 'returns true' do
        expect(task.overdue?).to be true
      end
    end

    context 'when the due date is in the future' do
      let(:task) { FactoryBot.build(:individual_task, due_date: 1.day.from_now, individual_project: project) }

      it 'returns false' do
        expect(task.overdue?).to be false
      end
    end
  end
end
