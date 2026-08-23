# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Posts', type: :request do
  let!(:admin) { FactoryBot.create(:user, role: 'admin') }

  before do
    login_as(admin, scope: :user)
  end

  describe 'POST /admin/posts' do
    it 'creates a post with permitted params' do
      expect do
        post admin_posts_path, params: {
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
        post admin_posts_path, params: {
          post: {
            body: 'This is my post.'
          }
        }
      end.not_to change(Post, :count)

      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe 'PATCH /admin/posts/:id' do
    let!(:post_record) { Post.create!(title: 'Old Title', body: 'Old body') }

    it 'updates a post with permitted params' do
      patch admin_post_path(post_record), params: {
        post: {
          title: 'Updated Title',
          body: 'Updated body'
        }
      }

      post_record.reload

      expect(post_record.title).to eq('Updated Title')
      expect(post_record.body).to eq('Updated body')
    end

    it 'does not update post with invalid values' do
      patch admin_post_path(post_record), params: {
        post: {
          title: nil
        }
      }

      post_record.reload

      expect(post_record.title).to eq('Old Title')
      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe 'DELETE /admin/posts/:id' do
    let!(:post_record) { Post.create!(title: 'Delete Me', body: 'Body') }

    it 'destroys the post' do
      expect do
        delete admin_post_path(post_record)
      end.to change(Post, :count).by(-1)

      expect(response).to have_http_status(:see_other)
    end
  end
end
