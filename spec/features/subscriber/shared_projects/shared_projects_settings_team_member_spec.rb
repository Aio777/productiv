# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Shared Projects and Workspace', type: :feature do
  let!(:lead) { FactoryBot.create(:user, role: 'subscriber', first_name: 'lead', last_name: 'user') }
  let!(:member) { FactoryBot.create(:user, role: 'subscriber', first_name: 'member', last_name: 'user') }
  let!(:project) { FactoryBot.create(:team_project, name: 'Test Project', description: 'Test Description') }
  let!(:member_membership) { FactoryBot.create(:team_project_member, user: member, team_project: project) }

  let!(:categories) do
    [
      FactoryBot.create(:radar_category, team_project: project, name: 'Skill A'),
      FactoryBot.create(:radar_category, team_project: project, name: 'Skill B'),
      FactoryBot.create(:radar_category, team_project: project, name: 'Skill C')
    ]
  end

  describe 'Team Member Settings' do
    before do
      FactoryBot.create(:team_project_member, :team_lead, user: lead, team_project: project)
      login_as(member, scope: :user)

      visit subscriber_shared_project_path(project)

      within('.subscriber-top-navbar') do
        click_on 'Settings'
      end
    end

    specify 'displays project information as read-only' do
      expect(page).to have_field('Project Name', with: 'Test Project', disabled: true)
      expect(page).to have_field('Description', with: 'Test Description', disabled: true)
      expect(page).to have_field('Team Lead', with: 'lead user', disabled: true)
    end

    specify 'can submit radar ratings and persist them', :js do
      sliders = all('.shared-project-skill-slider')

      sliders[0].set(5)
      sliders[1].set(4)
      sliders[2].set(3)

      click_button 'Save Settings'

      expect(page).to have_current_path(subscriber_shared_project_settings_path(project))

      within('.shared-project-skills-list') do
        rows = all('.shared-project-user-skill-row')

        expect(rows[0].find('input').value).to eq('5')
        expect(rows[1].find('input').value).to eq('4')
        expect(rows[2].find('input').value).to eq('3')
      end

      member_membership.reload

      ratings = member_membership.radar_ratings.order(:radar_category_id).pluck(:category_rating)
      expect(ratings).to contain_exactly(5, 4, 3)

      sliders = all('.shared-project-skill-slider')

      sliders[0].set(1)
      sliders[1].set(2)
      sliders[2].set(3)

      click_button 'Save Settings'

      expect(page).to have_current_path(subscriber_shared_project_settings_path(project))

      within('.shared-project-skills-list') do
        rows = all('.shared-project-user-skill-row')

        expect(rows[0].find('input').value).to eq('1')
        expect(rows[1].find('input').value).to eq('2')
        expect(rows[2].find('input').value).to eq('3')
      end

      member_membership.reload
      expect(member_membership.radar_ratings.count).to eq(3)
      expect(member_membership.radar_ratings.find_by(radar_category: categories[0]).category_rating).to eq(1)
      expect(member_membership.radar_ratings.find_by(radar_category: categories[1]).category_rating).to eq(2)
      expect(member_membership.radar_ratings.find_by(radar_category: categories[2]).category_rating).to eq(3)
    end

    specify 'Will see a message if no radar categories have been set up' do
      project.radar_categories.destroy_all
      visit subscriber_shared_project_settings_path(project)

      within('.shared-project-skills-empty') do
        expect(page).to have_content('No radar chart available yet')
        expect(page).to have_content('Your team lead has not set up any radar categories for this project.')
      end
    end

    specify 'can leave the project', :js do
      expect(page).to have_current_path(subscriber_shared_project_settings_path(project))

      page.execute_script(<<~JS)
        window.confirm = () => true;

        const btn = Array.from(document.querySelectorAll('button, a'))
          .find(el => el.textContent.trim() === 'Leave Project');

        btn.click();
      JS

      expect(page).to have_current_path(subscriber_shared_projects_path)

      within('.projects-grid') do
        expect(page).not_to have_content('Test Project')
      end

      expect(project.team_project_members.where(user: member)).to be_empty
    end
  end
end
