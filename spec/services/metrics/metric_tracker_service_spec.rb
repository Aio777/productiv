# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Metrics::MetricTrackerService do
  let(:tracker) { instance_spy(Ahoy::Tracker) }
  let(:request) { instance_double(ActionDispatch::Request, path_parameters: { controller: 'pages', action: 'home' }) }
  let(:service) { described_class.new(tracker) }
  let(:subscriber) { FactoryBot.create(:user, role: 'subscriber') }
  let(:individual_task) { FactoryBot.create(:individual_task, individual_project: subscriber.individual_project) }
  let(:item) { FactoryBot.create(:pot_item) }
  let(:team_project) { FactoryBot.create(:team_project) }
  let(:shared_task) do
    shared_task = FactoryBot.create(:team_project_task, team_project: team_project)
    team_project_subscriber = FactoryBot.create(:team_project_member, user: subscriber, team_project: team_project)
    FactoryBot.create(:team_task_assignment, team_project_task: shared_task,
                                             team_project_member: team_project_subscriber)

    shared_task
  end

  describe '#track_registering_interest' do
    it 'correctly calls the Ahoy::Tracker track method' do
      service.track_registering_interest(request)

      expect(tracker).to have_received(:track).with(
        Metrics::LandingPageMetrics::AHOY_EVENT_NAMES[:REGISTERED_INTEREST],
        request.path_parameters
      )
    end
  end

  describe '#track_visiting_landing_page' do
    it 'correctly calls the Ahoy::Tracker track method' do
      service.track_visiting_landing_page(request)

      expect(tracker).to have_received(:track).with(
        Metrics::LandingPageMetrics::AHOY_EVENT_NAMES[:VISITED_LANDING_PAGE],
        request.path_parameters
      )
    end
  end

  describe '#track_posted_question' do
    it 'correctly calls the Ahoy::Tracker track method' do
      service.track_posted_question(request)

      expect(tracker).to have_received(:track).with(
        Metrics::LandingPageMetrics::AHOY_EVENT_NAMES[:POSTED_QUESTION],
        request.path_parameters
      )
    end
  end

  describe '#track_ai_breakdown_individual_task' do
    it 'correctly calls the Ahoy::Tracker track method' do
      service.track_ai_breakdown_individual_task(subscriber.id, request)

      expect(tracker).to have_received(:track).with(
        "User ##{subscriber.id} #{
          Metrics::FeatureEngagementMetrics::AHOY_EVENT_NAMES[:BREAKDOWN_AI_INDIVIDUAL_TASK_PREFIX]
        }",
        request.path_parameters
      )
    end
  end

  describe '#track_ai_breakdown_shared_task' do
    it 'correctly calls the Ahoy::Tracker track method' do
      service.track_ai_breakdown_shared_task(subscriber.id, request)

      expect(tracker).to have_received(:track).with(
        "User ##{subscriber.id} #{
          Metrics::FeatureEngagementMetrics::AHOY_EVENT_NAMES[:BREAKDOWN_AI_SHARED_TASK_PREFIX]
        }",
        request.path_parameters
      )
    end
  end

  describe '#track_individual_task_created' do
    it 'correctly calls the Ahoy::Tracker track method' do
      service.track_individual_task_created(subscriber.id, individual_task.id, request)

      expect(tracker).to have_received(:track).with(
        "User ##{subscriber.id} #{
          Metrics::FeatureEngagementMetrics::AHOY_EVENT_NAMES[:CREATED_INDIVIDUAL_TASK_PREFIX]
        } ##{individual_task.id}",
        request.path_parameters
      )
    end
  end

  describe '#track_individual_task_reminder_set' do
    it 'correctly calls the Ahoy::Tracker track method' do
      service.track_individual_task_reminder_set(subscriber.id, individual_task.id, request)

      expect(tracker).to have_received(:track).with(
        "User ##{subscriber.id} #{
          Metrics::FeatureEngagementMetrics::AHOY_EVENT_NAMES[:SET_REMINDER_ON_INDIVIDUAL_TASK_PREFIX]
        } ##{individual_task.id}",
        request.path_parameters
      )
    end
  end

  describe '#track_individual_task_reminder_updated' do
    it 'correctly calls the Ahoy::Tracker track method' do
      service.track_individual_task_reminder_updated(subscriber.id, individual_task.id, request)

      expect(tracker).to have_received(:track).with(
        "User ##{subscriber.id} #{
          Metrics::FeatureEngagementMetrics::AHOY_EVENT_NAMES[:UPDATED_REMINDER_ON_INDIVIDUAL_TASK_PREFIX]
        } ##{individual_task.id}",
        request.path_parameters
      )
    end
  end

  describe '#track_individual_task_completed' do
    it 'correctly calls the Ahoy::Tracker track method' do
      service.track_individual_task_completed(subscriber.id, individual_task.id, request)

      expect(tracker).to have_received(:track).with(
        "User ##{subscriber.id} #{
          Metrics::FeatureEngagementMetrics::AHOY_EVENT_NAMES[:COMPLETED_INDIVIDUAL_TASK_PREFIX]
        } ##{individual_task.id}",
        request.path_parameters
      )
    end
  end

  describe '#track_individual_task_points_earned' do
    it 'correctly calls the Ahoy::Tracker track method' do
      service.track_individual_task_points_earned(subscriber.id, individual_task.points, individual_task.id, request)

      expect(tracker).to have_received(:track).with(
        "User ##{subscriber.id} Earned #{individual_task.points} #{
          Metrics::GamificationMetrics::AHOY_EVENT_NAMES[:EARNED_POINTS_FROM_INDIVIDUAL_TASK_PREFIX]
        } ##{individual_task.id}",
        request.path_parameters
      )
    end
  end

  describe '#track_shop_purchase' do
    it 'correctly calls the Ahoy::Tracker track method' do
      service.track_shop_purchase(subscriber.id, item.id, request)

      expect(tracker).to have_received(:track).with(
        "User ##{subscriber.id} #{Metrics::GamificationMetrics::AHOY_EVENT_NAMES[:PURCHASED_ITEM_PREFIX]} ##{item.id}",
        request.path_parameters
      )
    end
  end

  describe '#track_accepting_join_project_notification' do
    it 'correctly calls the Ahoy::Tracker track method' do
      service.track_accepting_join_project_notification(subscriber.id, team_project.id, request)

      expect(tracker).to have_received(:track).with(
        "User ##{subscriber.id} #{
          Metrics::FeatureEngagementMetrics::AHOY_EVENT_NAMES[:ACCEPTED_TEAM_PROJECT_INVITATION_PREFIX]
        } ##{team_project.id}",
        request.path_parameters
      )
    end
  end

  describe '#track_rejecting_join_project_notification' do
    it 'correctly calls the Ahoy::Tracker track method' do
      service.track_rejecting_join_project_notification(subscriber.id, team_project.id, request)

      expect(tracker).to have_received(:track).with(
        "User ##{subscriber.id} #{
          Metrics::FeatureEngagementMetrics::AHOY_EVENT_NAMES[:REJECTED_TEAM_PROJECT_INVITATION_PREFIX]
        } ##{team_project.id}",
        request.path_parameters
      )
    end
  end

  describe '#track_plant_brought_to_life' do
    it 'correctly calls the Ahoy::Tracker track method' do
      service.track_plant_brought_to_life(subscriber.plant.id, subscriber.id, request)

      expect(tracker).to have_received(:track).with(
        "Plant ##{subscriber.plant.id} From User ##{subscriber.id} #{
          Metrics::GamificationMetrics::AHOY_EVENT_NAMES[:PLANT_BROUGHT_TO_LIFE_PREFIX]
        }",
        request.path_parameters
      )
    end
  end

  describe '#track_plant_revived_from_death' do
    it 'correctly calls the Ahoy::Tracker track method' do
      service.track_plant_revived_from_death(subscriber.plant.id, subscriber.id, request)

      expect(tracker).to have_received(:track).with(
        "Plant ##{subscriber.plant.id} From User ##{subscriber.id} #{
          Metrics::GamificationMetrics::AHOY_EVENT_NAMES[:PLANT_REVIVED_FROM_DEATH_PREFIX]
        }",
        request.path_parameters
      )
    end
  end

  describe '#track_plant_death' do
    it 'correctly calls the Ahoy::Tracker track method' do
      freeze_time do
        described_class.track_plant_death(subscriber)

        expect(Ahoy::Visit.count).to eq(1)
        expect(Ahoy::Visit.first.user).to eq(subscriber)
        expect(Ahoy::Visit.first.started_at).to eq(Time.current)

        expect(Ahoy::Event.count).to eq(1)
        expect(Ahoy::Event.first.user).to eq(subscriber)
        expect(Ahoy::Event.first.name).to eq("Plant ##{subscriber.plant.id} From User ##{subscriber.id} #{
          Metrics::GamificationMetrics::AHOY_EVENT_NAMES[:PLANT_DIED_PREFIX]
        }")
        expect(Ahoy::Event.first.time).to eq(Time.current)
      end
    end
  end

  describe '#track_shared_task_created' do
    it 'correctly calls the Ahoy::Tracker track method' do
      service.track_shared_task_created(subscriber.id, shared_task.id, request)

      expect(tracker).to have_received(:track).with(
        "User ##{subscriber.id} #{
          Metrics::FeatureEngagementMetrics::AHOY_EVENT_NAMES[:CREATED_SHARED_TASK_PREFIX]
        } ##{shared_task.id}",
        request.path_parameters
      )
    end
  end

  describe '#track_shared_task_reminder_set' do
    it 'correctly calls the Ahoy::Tracker track method' do
      service.track_shared_task_reminder_set(subscriber.id, shared_task.id, request)

      expect(tracker).to have_received(:track).with(
        "User ##{subscriber.id} #{
          Metrics::FeatureEngagementMetrics::AHOY_EVENT_NAMES[:SET_REMINDER_ON_SHARED_TASK_PREFIX]
        } ##{shared_task.id}",
        request.path_parameters
      )
    end
  end

  describe '#track_shared_task_reminder_updated' do
    it 'correctly calls the Ahoy::Tracker track method' do
      service.track_shared_task_reminder_updated(subscriber.id, shared_task.id, request)

      expect(tracker).to have_received(:track).with(
        "User ##{subscriber.id} #{
          Metrics::FeatureEngagementMetrics::AHOY_EVENT_NAMES[:UPDATED_REMINDER_ON_SHARED_TASK_PREFIX]
        } ##{shared_task.id}",
        request.path_parameters
      )
    end
  end

  describe '#track_shared_task_completed' do
    it 'correctly calls the Ahoy::Tracker track method' do
      service.track_shared_task_completed(subscriber.id, shared_task.id, request)

      expect(tracker).to have_received(:track).with(
        "User ##{subscriber.id} #{
          Metrics::FeatureEngagementMetrics::AHOY_EVENT_NAMES[:COMPLETED_SHARED_TASK_PREFIX]
        } ##{shared_task.id}",
        request.path_parameters
      )
    end
  end

  describe '#track_shared_task_points_earned' do
    it 'correctly calls the Ahoy::Tracker track method' do
      service.track_shared_task_points_earned(subscriber.id, shared_task.points, shared_task.id, request)

      expect(tracker).to have_received(:track).with(
        "User ##{subscriber.id} Earned #{shared_task.points} #{
          Metrics::GamificationMetrics::AHOY_EVENT_NAMES[:EARNED_POINTS_FROM_SHARED_TASK_PREFIX]
        } ##{shared_task.id}",
        request.path_parameters
      )
    end
  end

  describe '#track_user_signed_in' do
    it 'correctly calls the Ahoy::Tracker track method' do
      service.track_user_signed_in(subscriber.id, request)

      expect(tracker).to have_received(:track).with(
        "User ##{subscriber.id} #{Metrics::UserGrowthMetrics::AHOY_EVENT_NAMES[:USER_SIGNED_IN_PREFIX]}",
        request.path_parameters
      )
    end
  end
end
