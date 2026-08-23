# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Posts', type: :request do
  describe 'POST /posts' do
    it 'creates a post with permitted params' do
      expect do
        post posts_path, params: {
          post: {
            title: 'My Post',
            body: 'This is my post.'
          }
        }
      end.to change(Post, :count).by(1)

      post = Post.last
      expect(post.title).to eq('My Post')
      expect(post.body).to eq('This is my post.')
    end

    it 'does not create post with invalid values' do
      expect do
        post posts_path, params: {
          post: {
            body: 'This is my post.'
          }
        }
      end.not_to change(Post, :count)

      expect(response).to have_http_status(:unprocessable_content)
    end
  end
end
