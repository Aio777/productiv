# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Users', type: :request do
  let!(:admin) { FactoryBot.create(:user, role: 'admin') }

  before do
    login_as(admin, scope: :user)
  end

  describe 'DELETE /admin/users/:id' do
    let!(:user) do
      User.create!(
        first_name: 'Example',
        last_name: 'User',
        email: 'TestUser@example.com',
        password: 'Password@1234',
        role: 'subscriber'
      )
    end

    it 'deletes the user' do
      expect do
        delete admin_user_path(user)
      end.to change(User, :count).by(-1)

      expect(URI(response.location).path).to eq(admin_users_path)
    end
  end

  describe 'POST /users' do
    it 'creates a user with valid params' do
      expect do
        post admin_users_path, params: {
          user: {
            first_name: 'John',
            last_name: 'Doe',
            email: 'john.doe@example.com',
            role: 'admin'
          }
        }
      end.to change(User, :count).by(1)

      user = User.last
      expect(user.first_name).to eq('John')
      expect(user.last_name).to eq('Doe')
      expect(user.email).to eq('john.doe@example.com')
    end

    it 'does not create user with invalid values' do
      expect do
        post admin_users_path, params: {
          user: {
            first_name: nil,
            last_name: 'Doe',
            email: 'invalid-email'
          }
        }
      end.not_to change(User, :count)
      expect(response).to have_http_status(:unprocessable_content)
    end

    it 'does not create duplicate users with valid values' do
      User.create!(first_name: 'Example', last_name: 'User', email: 'Duplicate@example.com', password: 'Password@1234',
                   role: 'subscriber')
      expect do
        post admin_users_path, params: {
          user: {
            first_name: 'John',
            last_name: 'Doe',
            email: 'Duplicate@example.com'
          }
        }
      end.not_to change(User, :count)
      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe 'POST /admin/users/:id' do
    let!(:user) do
      User.create!(
        first_name: 'Example',
        last_name: 'User',
        email: 'TestUser@example.com',
        password: 'Password@1234',
        role: 'subscriber'
      )
    end

    it 'updates a user with valid parameters' do
      expect do
        patch admin_user_path(user), params: {
          user: {
            first_name: 'Updated',
            last_name: 'User',
            email: 'updated.user@example.com'
          }
        }
      end.not_to change(User, :count)

      user.reload
      expect(user.first_name).to eq('Updated')
      expect(user.last_name).to eq('User')
      expect(user.email).to eq('updated.user@example.com')
    end

    it 'rejects updates with invalid parameters' do
      expect do
        patch admin_user_path(user), params: {
          user: {
            first_name: nil,
            last_name: 'User',
            email: nil
          }
        }
      end.not_to change(User, :count)

      expect(response).to have_http_status(:unprocessable_content)
    end
  end
end
