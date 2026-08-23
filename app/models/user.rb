# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  current_sign_in_at     :datetime
#  current_sign_in_ip     :string
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  failed_attempts        :integer          default(0), not null
#  first_name             :string           default("")
#  invitation_accepted_at :datetime
#  invitation_created_at  :datetime
#  invitation_limit       :integer
#  invitation_sent_at     :datetime
#  invitation_token       :string
#  invited_by_type        :string
#  last_name              :string           default("")
#  last_sign_in_at        :datetime
#  last_sign_in_ip        :string
#  layout                 :integer
#  locked_at              :datetime
#  points                 :integer          default(0), not null
#  registration_ip        :string
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  role                   :string           default("subscriber")
#  sign_in_count          :integer          default(0), not null
#  unlock_token           :string
#  was_subscriber         :boolean          default(TRUE), not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  invited_by_id          :integer
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_invitation_token      (invitation_token) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#
class User < ApplicationRecord
  before_validation :set_layout, on: :create
  after_commit :create_default_individual_project, on: :create
  after_create :create_plant, if: :subscriber?

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, presence: true, uniqueness: true
  validate :password_strength

  has_many :visits, class_name: 'Ahoy::Visit', dependent: :destroy
  has_many :events, class_name: 'Ahoy::Event', dependent: :destroy

  has_many :user_items, dependent: :destroy
  has_many :items, through: :user_items
  has_one :plant, dependent: :destroy

  has_one :individual_project, dependent: :destroy

  has_many :team_project_members, dependent: :destroy
  has_many :team_projects, through: :team_project_members

  has_many :task_assignments
  has_many :assigned_tasks, through: :task_assignments, source: :team_project_task

  has_many :notifications, dependent: :destroy

  # Include default devise modules. Others available are:
  # :confirmable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable,
         :rememberable, :validatable, :trackable, :invitable, invite_for: 1.weeks

  def admin?
    role == 'admin'
  end

  def reporter?
    role == 'reporter'
  end

  def subscriber?
    role == 'subscriber'
  end

  def unread_notifications_count
    notifications.where(read: false).count
  end

  private

  # Layouts are integers between 0 and 15. Default: 15 - displays all 4 graphs on the User's Dashboard
  def set_layout
    self.layout = 15 if layout.nil?
  end

  def create_default_individual_project
    create_individual_project! unless individual_project.present?
  end

  def create_plant
    Poro::Plant.create_active_record_plant(self)
  end

  def password_strength
    return if password.blank?

    return if password.match?(/\A(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^A-Za-z0-9])/)

    errors.add :password,
               'must include at least one lowercase letter, one uppercase letter, one number, and one special character'
  end
end
