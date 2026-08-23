# frozen_string_literal: true

class Reporter::MetricsController < Reporter::BaseController
  def landing_page_metrics
    @landing_page_metrics = Metrics::LandingPageMetrics.landing_page_metrics(:day, :day)
  end

  def feature_engagement_metrics
    @feature_engagement_metrics = Metrics::FeatureEngagementMetrics.feature_engagement_metrics
  end

  def gamification_metrics
    @gamification_metrics = Metrics::GamificationMetrics.gamification_metrics
  end

  def user_growth_metrics
    @user_growth_metrics = Metrics::UserGrowthMetrics.user_growth_metrics
  end
end
