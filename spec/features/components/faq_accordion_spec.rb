# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Interacting with the FAQ Accordion', :js do
  scenario "I can view a post once and see the post's interest counter increase to one" do
    post = FactoryBot.create(:post, title: 'Test FAQ', body: 'Test body')
    FactoryBot.create(:post, parent_id: post.id, title: 'Admin Reply', body: 'Reply body', answer_by_admin: true)

    visit root_path

    faq_button_selector = "[data-testid='faq-button-#{post.id}']"
    find(faq_button_selector).click

    expect(page).to have_css("#{faq_button_selector}[aria-expanded='true']")

    admin = FactoryBot.create(:user, role: 'admin')
    login_as admin, scope: :user

    visit admin_posts_path

    faq_row = find('table tbody tr', text: post.title)

    expect(faq_row).to have_content post.title
    expect(faq_row).to have_content post.body
    expect(faq_row).to have_content '1'
  end
end
