# frozen_string_literal: true

class Metrics::MetricTrackerService
  def initialize(tracker)
    @tracker = tracker
  end

  def track_registering_interest(request)
    @tracker.track Metrics::LandingPageMetrics::AHOY_EVENT_NAMES[:REGISTERED_INTEREST], request.path_parameters
  end

  def track_visiting_landing_page(request)
    @tracker.track Metrics::LandingPageMetrics::AHOY_EVENT_NAMES[:VISITED_LANDING_PAGE], request.path_parameters
  end

  def track_posted_question(request)
    @tracker.track Metrics::LandingPageMetrics::AHOY_EVENT_NAMES[:POSTED_QUESTION], request.path_parameters
  end

  def track_ai_breakdown_individual_task(user_id, request)
    @tracker.track(
      "User ##{user_id} #{
        Metrics::FeatureEngagementMetrics::AHOY_EVENT_NAMES[:BREAKDOWN_AI_INDIVIDUAL_TASK_PREFIX]
      }", request.path_parameters
    )
  end

  def track_ai_breakdown_shared_task(user_id, request)
    @tracker.track(
      "User ##{user_id} #{
        Metrics::FeatureEngagementMetrics::AHOY_EVENT_NAMES[:BREAKDOWN_AI_SHARED_TASK_PREFIX]
      }", request.path_parameters
    )
  end

  def track_individual_task_created(user_id, task_id, request)
    @tracker.track(
      "User ##{user_id} #{
        Metrics::FeatureEngagementMetrics::AHOY_EVENT_NAMES[:CREATED_INDIVIDUAL_TASK_PREFIX]
      } ##{task_id}", request.path_parameters
    )
  end

  def track_individual_task_reminder_set(user_id, task_id, request)
    @tracker.track(
      "User ##{user_id} #{
        Metrics::FeatureEngagementMetrics::AHOY_EVENT_NAMES[:SET_REMINDER_ON_INDIVIDUAL_TASK_PREFIX]
      } ##{task_id}", request.path_parameters
    )
  end

  def track_individual_task_reminder_updated(user_id, task_id, request)
    @tracker.track(
      "User ##{user_id} #{
        Metrics::FeatureEngagementMetrics::AHOY_EVENT_NAMES[:UPDATED_REMINDER_ON_INDIVIDUAL_TASK_PREFIX]
      } ##{task_id}", request.path_parameters
    )
  end

  def track_individual_task_completed(user_id, task_id, request)
    @tracker.track(
      "User ##{user_id} #{
        Metrics::FeatureEngagementMetrics::AHOY_EVENT_NAMES[:COMPLETED_INDIVIDUAL_TASK_PREFIX]
      } ##{task_id}", request.path_parameters
    )
  end

  def track_individual_task_points_earned(user_id, points, task_id, request)
    @tracker.track(
      "User ##{user_id} Earned #{points} #{
        Metrics::GamificationMetrics::AHOY_EVENT_NAMES[:EARNED_POINTS_FROM_INDIVIDUAL_TASK_PREFIX]
      } ##{task_id}", request.path_parameters
    )
  end

  def track_shop_purchase(user_id, item_id, request)
    @tracker.track "User ##{user_id} #{
      Metrics::GamificationMetrics::AHOY_EVENT_NAMES[:PURCHASED_ITEM_PREFIX]
    } ##{item_id}", request.path_parameters
  end

  def track_accepting_join_project_notification(user_id, team_project_id, request)
    @tracker.track "User ##{user_id} #{
      Metrics::FeatureEngagementMetrics::AHOY_EVENT_NAMES[:ACCEPTED_TEAM_PROJECT_INVITATION_PREFIX]
    } ##{team_project_id}", request.path_parameters
  end

  def track_rejecting_join_project_notification(user_id, team_project_id, request)
    @tracker.track "User ##{user_id} #{
      Metrics::FeatureEngagementMetrics::AHOY_EVENT_NAMES[:REJECTED_TEAM_PROJECT_INVITATION_PREFIX]
    } ##{team_project_id}", request.path_parameters
  end

  def track_plant_brought_to_life(plant_id, user_id, request)
    @tracker.track "Plant ##{plant_id} From User ##{user_id} #{
      Metrics::GamificationMetrics::AHOY_EVENT_NAMES[:PLANT_BROUGHT_TO_LIFE_PREFIX]
    }", request.path_parameters
  end

  def track_plant_revived_from_death(plant_id, user_id, request)
    @tracker.track "Plant ##{plant_id} From User ##{user_id} #{
      Metrics::GamificationMetrics::AHOY_EVENT_NAMES[:PLANT_REVIVED_FROM_DEATH_PREFIX]
    }", request.path_parameters
  end

  # This is a class method because this is executed from a service class, not a controller - therefore, no tracker
  # instance variable and tracking done manually so no need to make an instance of this class.
  def self.track_plant_death(user)
    ahoy_visit = Ahoy::Visit.create!(user: user, started_at: Time.zone.now)
    Ahoy::Event.create!(
      visit: ahoy_visit,
      user: user,
      name: "Plant ##{user.plant.id} From User ##{user.id} #{
        Metrics::GamificationMetrics::AHOY_EVENT_NAMES[:PLANT_DIED_PREFIX]
      }",
      time: Time.zone.now
    )
  end

  def track_shared_task_created(user_id, task_id, request)
    @tracker.track(
      "User ##{user_id} #{
        Metrics::FeatureEngagementMetrics::AHOY_EVENT_NAMES[:CREATED_SHARED_TASK_PREFIX]
      } ##{task_id}", request.path_parameters
    )
  end

  def track_shared_task_reminder_set(user_id, task_id, request)
    @tracker.track(
      "User ##{user_id} #{
        Metrics::FeatureEngagementMetrics::AHOY_EVENT_NAMES[:SET_REMINDER_ON_SHARED_TASK_PREFIX]
      } ##{task_id}", request.path_parameters
    )
  end

  def track_shared_task_reminder_updated(user_id, task_id, request)
    @tracker.track(
      "User ##{user_id} #{
        Metrics::FeatureEngagementMetrics::AHOY_EVENT_NAMES[:UPDATED_REMINDER_ON_SHARED_TASK_PREFIX]
      } ##{task_id}", request.path_parameters
    )
  end

  def track_shared_task_completed(user_id, task_id, request)
    @tracker.track(
      "User ##{user_id} #{
        Metrics::FeatureEngagementMetrics::AHOY_EVENT_NAMES[:COMPLETED_SHARED_TASK_PREFIX]
      } ##{task_id}", request.path_parameters
    )
  end

  def track_shared_task_points_earned(user_id, points, task_id, request)
    @tracker.track(
      "User ##{user_id} Earned #{points} #{
        Metrics::GamificationMetrics::AHOY_EVENT_NAMES[:EARNED_POINTS_FROM_SHARED_TASK_PREFIX]
      } ##{task_id}", request.path_parameters
    )
  end

  def track_user_signed_in(user_id, request)
    @tracker.track("User ##{user_id} #{Metrics::UserGrowthMetrics::AHOY_EVENT_NAMES[:USER_SIGNED_IN_PREFIX]}",
                   request.path_parameters)
  end
end
