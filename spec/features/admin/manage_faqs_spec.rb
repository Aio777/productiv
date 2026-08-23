# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin manages FAQs', type: :feature do
  it 'admin can visit FAQ list page' do
    admin = FactoryBot.create(:user, role: 'admin')
    login_as admin, scope: :user
    visit admin_posts_path
    expect(page).to have_current_path(admin_posts_path)
    expect(page).to have_content('FAQs')
  end

  it 'reporter is redirected to root' do
    reporter = FactoryBot.create(:user, role: 'reporter')
    login_as reporter, scope: :user
    visit admin_posts_path
    expect(page).to have_current_path(root_path)
    expect(page).to have_content('Logout')
  end

  it 'signee (deactivated user) is redirected to root' do
    signee = FactoryBot.create(:user, role: 'signee')
    login_as signee, scope: :user
    visit admin_posts_path
    expect(page).to have_current_path(root_path)
    expect(page).to have_content('Logout')
  end

  it 'non user is redirected to root' do
    visit admin_posts_path
    expect(page).to have_current_path(new_user_session_path)
    expect(page).to have_content('Log In')
  end

  it 'displays new FAQs' do
    admin = FactoryBot.create(:user, role: 'admin')
    post1 = FactoryBot.create(:post, created_at: 2.days.ago)
    login_as admin, scope: :user
    visit admin_posts_path
    expect(page).to have_content(post1.title)
    expect(page).to have_content(post1.body)
    expect(page).to have_content(post1.interest_count)
  end

  it 'displays all FAQs' do
    admin = FactoryBot.create(:user, role: 'admin')
    posts = FactoryBot.create_list(:post, 5)

    login_as admin, scope: :user
    visit admin_posts_path

    displayed_rows_count = page.all('table tbody tr').count
    expect(displayed_rows_count).to eq(posts.count)

    posts.each do |post|
      expect(page).to have_content(post.title)
    end
  end

  it 'deleting anFAQ removes the FAQ from list page' do
    admin = FactoryBot.create(:user, role: 'admin')
    post1 = FactoryBot.create(:post, created_at: 2.days.ago)
    login_as admin, scope: :user
    visit admin_posts_path
    expect(page).to have_content(post1.title)
    within(:xpath, "//tr[td[contains(text(), '#{post1.title}')]]") do
      click_on 'Destroy'
    end
    expect(page).not_to have_content(post1.title)
  end

  it "navigates to edit FAQ on 'Edit FAQ' click", :js do
    admin = FactoryBot.create(:user, role: 'admin')
    post1 = FactoryBot.create(:post, created_at: 2.days.ago, interest_count: 5)
    login_as admin, scope: :user
    visit admin_posts_path
    within('tr', text: post1.title) do
      click_link 'Edit FAQ'
    end
    expect(page).to have_content('Edit FAQ')
    expect(page).to have_content(post1.body)
  end

  it 'Manage Response loads admin response content if reply exists', :js do
    admin = FactoryBot.create(:user, role: 'admin')
    post1 = FactoryBot.create(:post, created_at: 2.days.ago, interest_count: 5)
    reply1 = FactoryBot.create(:post, created_at: 2.days.ago, interest_count: 5,
                                      answer_by_admin: true, parent_id: post1.id)
    login_as admin, scope: :user
    visit admin_posts_path

    within('tr', text: post1.title) do
      click_link 'Manage Response'
    end

    expect(page).to have_selector('turbo-frame#modal', wait: 5)

    within('turbo-frame#modal') do
      expect(page).to have_content('Edit Admin Response')
      expect(page).to have_content(reply1.body)
    end
  end

  it 'Manage Response loads empty admin response content if no reply exists', :js do
    admin = FactoryBot.create(:user, role: 'admin')
    post1 = FactoryBot.create(:post, created_at: 2.days.ago, interest_count: 5)

    login_as admin, scope: :user
    visit admin_posts_path

    within('tr', text: post1.title) do
      click_link 'Manage Response'
    end

    expect(page).to have_selector('turbo-frame#modal', wait: 5)

    within('turbo-frame#modal') do
      expect(page).to have_content('Add Admin Response')
      expect(page).to have_field('Admin Response', with: '')
    end
  end

  it 'can edit an admin reply to FAQ', :js do
    admin = FactoryBot.create(:user, role: 'admin')
    post1 = FactoryBot.create(:post, created_at: 2.days.ago, interest_count: 5)
    FactoryBot.create(:post, created_at: 2.days.ago, interest_count: 5,
                             answer_by_admin: true, parent_id: post1.id)
    login_as admin, scope: :user
    visit admin_posts_path

    within('tr', text: post1.title) do
      click_link 'Manage Response'
    end

    fill_in 'Title', with: 'Updated FAQ Title'
    fill_in 'Admin Response', with: 'Updated FAQ Body'

    page.execute_script(<<~JS)
      window.confirm = () => true;
      window.alert = () => true;

      const button = Array.from(document.querySelectorAll('button, input[type="submit"]'))
        .find(el => el.textContent.trim() === 'Save' || el.value === 'Save');

      button.click();
    JS

    visit admin_posts_path

    within('tr', text: post1.title) do
      click_link 'Manage Response'
    end

    expect(page).to have_content('Updated FAQ Body')
    expect(page).to have_content('Edit Admin Response')
  end

  it 'Editing an FAQ updates the FAQ on the list page', :js do
    admin = FactoryBot.create(:user, role: 'admin')
    post1 = FactoryBot.create(:post, created_at: 2.days.ago, interest_count: 5)
    login_as admin, scope: :user
    visit admin_posts_path

    within('tr', text: post1.title) do
      click_link 'Edit FAQ'
    end

    fill_in 'Title', with: 'Updated FAQ Title'
    fill_in 'Content', with: 'Updated FAQ Body'

    page.execute_script(<<~JS)
      window.confirm = () => true;
      window.alert = () => true;

      const button = Array.from(document.querySelectorAll('button, input[type="submit"]'))
        .find(el => el.textContent.trim() === 'Save' || el.value === 'Save');

      button.click();
    JS

    visit admin_posts_path
    expect(page).to have_current_path(admin_posts_path)
    expect(page).to have_content('Updated FAQ Title')
    expect(page).to have_content('Updated FAQ Body')
  end

  it 'when hide FAQ hides an FAQ from the list page', :js do
    admin = FactoryBot.create(:user, role: 'admin')
    post1 = FactoryBot.create(:post, created_at: 2.days.ago, interest_count: 5)
    login_as admin, scope: :user
    visit admin_posts_path

    within('tr', text: post1.title) do
      click_link 'Edit FAQ'
    end
    fill_in 'Title', with: 'Updated FAQ Title'
    fill_in 'Content', with: 'Updated FAQ Body'
    check 'Hide from public view'

    page.execute_script(<<~JS)
      window.confirm = () => true;
      window.alert = () => true;

      const button = Array.from(document.querySelectorAll('button, input[type="submit"]'))
        .find(el => el.textContent.trim() === 'Save' || el.value === 'Save');

      button.click();
    JS

    visit root_path
    expect(page).not_to have_content('Updated FAQ Title')
  end

  it 'when create FAQ then shows on FAQ list page' do
    visit root_path

    fill_in 'post_title', with: 'Updated FAQ Title'
    fill_in 'post_body', with: 'Updated FAQ Body'
    click_button 'Post'

    admin = FactoryBot.create(:user, role: 'admin')
    login_as admin, scope: :user
    visit admin_posts_path

    expect(page).to have_content('Updated FAQ Title')
    expect(page).to have_content('Updated FAQ Body')
  end
end
