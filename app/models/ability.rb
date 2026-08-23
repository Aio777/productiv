# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new

    if user.role == 'admin'
      can :access, :admin
      can :access, :reporter
      return
    end

    if user.role == 'reporter'
      can :access, :reporter
      can :read, :all
      return
    end

    if user.role == 'subscriber'
      can :access, :subscriber
      return
    end

    can :create, Post
    can :create, Review
    can :create, Interest
    can :read, Post
  end
end
