# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Custom Errors', type: :request do
  let!(:admin) { FactoryBot.create(:user, role: 'admin', first_name: 'admin') }

  before do
    login_as(admin, scope: :user)
  end

  it 'returns 400 when params are missing' do
    post '/reviews', params: {}

    expect(response).to have_http_status(:bad_request)
  end

  it 'returns 404 for unknown route' do
    get '/this-does-not-exist'

    expect(response).to have_http_status(:not_found)
  end

  it 'returns 406 when format not accepted' do
    get admin_posts_path, headers: { 'ACCEPT' => 'application/xml' }

    expect(response).to have_http_status(:not_acceptable)
  end

  it 'returns 422 when data is invalid' do
    post '/posts',
         params: { post: { title: ' ' } },
         headers: { 'ACCEPT' => 'application/json' }

    expect(response).to have_http_status(:unprocessable_content)
  end

  it 'returns 500 for internal server error' do
    allow(Rails.application).to receive(:env_config).and_wrap_original do |m|
      m.call.merge(
        'action_dispatch.show_detailed_exceptions' => false,
        'action_dispatch.show_exceptions' => :all
      )
    end

    allow(Post).to receive(:where).and_raise('Instant Crash')
    get admin_posts_path

    expect(response).to have_http_status(:internal_server_error)
  end

  it 'renders the 500 page even when the database is disconnected' do
    allow(Rails.application).to receive(:env_config).and_wrap_original do |m|
      m.call.merge(
        'action_dispatch.show_detailed_exceptions' => false,
        'action_dispatch.show_exceptions' => :all
      )
    end

    allow(ActiveRecord::Base.connection).to receive(:active?).and_raise(ActiveRecord::ConnectionNotEstablished)
    allow(Post).to receive(:where).and_raise(ActiveRecord::ConnectionNotEstablished)
    get admin_posts_path

    expect(response).to have_http_status(:internal_server_error)
  end

  it 'returns 502 when an upstream service fails' do
    allow(Rails.application).to receive(:env_config).and_wrap_original do |m|
      m.call.merge(
        'action_dispatch.show_detailed_exceptions' => false,
        'action_dispatch.show_exceptions' => :all
      )
    end

    allow(ActionDispatch::ExceptionWrapper).to receive(:status_code_for_exception).and_return(502)
    allow(Post).to receive(:where).and_raise(RuntimeError, 'Bad Gateway Trigger')
    get admin_posts_path

    expect(response).to have_http_status(:bad_gateway)
  end

  it 'returns 503 when the service is unavailable' do
    allow(Rails.application).to receive(:env_config).and_wrap_original do |m|
      m.call.merge(
        'action_dispatch.show_detailed_exceptions' => false,
        'action_dispatch.show_exceptions' => :all
      )
    end

    allow(ActionDispatch::ExceptionWrapper).to receive(:status_code_for_exception).and_return(503)
    allow(Post).to receive(:where).and_raise(RuntimeError, 'Service Overloaded Trigger')
    get admin_posts_path

    expect(response).to have_http_status(:service_unavailable)
  end

  describe 'Dashboard links on error pages' do
    context 'when database is available' do
      it 'shows Admin and Reporter Dashboard links when logged in as admin' do
        admin = FactoryBot.create(:user, role: 'admin')
        login_as(admin, scope: :user)
        get '/500'

        expect(response.body).to include('Return to Admin Dashboard')
        expect(response.body).to include('Return to Reporter Dashboard')
        expect(response.body).not_to include('Return to My Dashboard')
      end

      it 'shows Reporter Dashboard link when logged in as reporter' do
        reporter = FactoryBot.create(:user, role: 'reporter')
        login_as(reporter, scope: :user)
        get '/500'

        expect(response.body).to include('Return to Reporter Dashboard')
        expect(response.body).not_to include('Return to Admin Dashboard')
        expect(response.body).not_to include('Return to My Dashboard')
      end

      it 'shows Subscriber Dashboard link when logged in as subscriber' do
        subscriber = FactoryBot.create(:user, role: 'subscriber')
        login_as(subscriber, scope: :user)
        get '/500'

        expect(response.body).to include('Return to My Dashboard')
        expect(response.body).not_to include('Return to Admin Dashboard')
        expect(response.body).not_to include('Return to Reporter Dashboard')
      end

      it 'only shows the Home Page link for non-logged in users' do
        logout(:user)
        get '/500'

        expect(response.body).to include('Return to Home Page')
        expect(response.body).not_to include('Return to Admin Dashboard')
        expect(response.body).not_to include('Return to Reporter Dashboard')
        expect(response.body).not_to include('Return to My Dashboard')
      end
    end

    context 'when database is down' do
      it 'only shows the Home Page link and hides all dashboard links' do
        admin = FactoryBot.create(:user, role: 'admin')
        login_as(admin, scope: :user)

        allow(ActiveRecord::Base.connection).to receive(:active?).and_raise(ActiveRecord::ConnectionNotEstablished)
        get '/500'

        expect(response.body).to include('Return to Home Page')
        expect(response.body).not_to include('Return to Admin Dashboard')
        expect(response.body).not_to include('Return to Reporter Dashboard')
        expect(response.body).not_to include('Return to My Dashboard')
      end
    end
  end
end
