# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Reviews', type: :request do
  describe 'POST /reviews' do
    it 'creates a review with permitted params' do
      expect do
        post reviews_path, params: {
          review: {
            name: 'John',
            rating: 5,
            body: 'Great!'
          }
        }
      end.to change(Review, :count).by(1)

      review = Review.last
      expect(review.name).to eq('John')
      expect(review.rating).to eq(5)
      expect(review.body).to eq('Great!')
      expect(review.hidden).to be(true)
    end

    it 'does not create review with invalid values' do
      expect do
        post reviews_path, params: {
          review: {
            name: nil,
            rating: 'hello'
          }
        }
      end.not_to change(Review, :count)
      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe 'POST /reviews/:id/upvote' do
    let!(:review) { Review.create!(name: 'John', rating: 5, body: 'Great!', hidden: false) }

    it 'increments positive_interest_count' do
      expect do
        post upvote_review_path(review)
      end.to change { review.reload.positive_interest_count }.by(1)

      expect(response).to have_http_status(:found)
    end

    it 'returns forbidden if already voted' do
      post upvote_review_path(review)
      review.reload

      expect do
        post upvote_review_path(review)
      end.not_to(change { review.reload.positive_interest_count })

      expect(response).to have_http_status(:forbidden)
    end
  end

  describe 'POST /reviews/:id/downvote' do
    let!(:review) { Review.create!(name: 'John', rating: 5, body: 'Great!', hidden: false) }

    it 'increments negative_interest_count' do
      expect do
        post downvote_review_path(review)
      end.to change { review.reload.negative_interest_count }.by(1)

      expect(response).to have_http_status(:found)
    end

    it 'returns forbidden if already voted' do
      post downvote_review_path(review)
      review.reload

      expect do
        post downvote_review_path(review)
      end.not_to(change { review.reload.negative_interest_count })

      expect(response).to have_http_status(:forbidden)
    end
  end
end
