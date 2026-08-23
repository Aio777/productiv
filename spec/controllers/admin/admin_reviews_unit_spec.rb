# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Reviews', type: :request do
  let!(:admin) { FactoryBot.create(:user, role: 'admin') }
  let!(:review) do
    Review.create!(
      name: 'John',
      rating: 5,
      body: 'Great!',
      hidden: true,
      review_index: 0
    )
  end

  before do
    login_as(admin, scope: :user)
  end

  describe 'POST /admin/dashboard/update_review' do
    it "updates the review's index" do
      post admin_update_review_path, params: {
        index: 1,
        review_id: review.id
      }

      expect(review.reload.review_index).to eq(1)
      expect(URI(response.location).path).to eq(admin_reviews_path)
    end
  end

  describe 'DELETE /admin/reviews/:id' do
    it 'deletes the review' do
      expect do
        delete admin_review_path(review)
      end.to change(Review, :count).by(-1)

      expect(URI(response.location).path).to eq(admin_reviews_path)
    end
  end
end
