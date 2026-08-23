puts "Starting seed..."

# --------------------------------------------------------
# HELPERS
# --------------------------------------------------------

def sample_time_within(days_back: 30)
  rand(days_back.days.ago..Time.current)
end

def future_time_within(days_forward: 30)
  rand(Time.current..days_forward.days.from_now)
end

def task_status_for_due_date(due_date)
  due_date < Time.current ? [true, false].sample : false
end

def difficulty_points(difficulty)
  case difficulty
  when "easy"   then rand(5..10)
  when "medium" then rand(15..25)
  when "hard"   then rand(30..50)
  else rand(5..20)
  end
end

def create_post_reply(parent_post, body:)
  Post.create!(
    parent_id: parent_post.id,
    title: "Official response",
    body: body,
    answer_by_admin: true,
    hidden: false
  )
end

# --------------------------------------------------------
# RESET DATA
# --------------------------------------------------------

puts "Clearing existing data..."

Ahoy::Event.delete_all if defined?(Ahoy::Event)
Ahoy::Visit.delete_all if defined?(Ahoy::Visit)

Notification.delete_all
RadarRating.delete_all
RadarCategory.delete_all
TeamTaskAssignment.delete_all
TeamProjectTask.delete_all
SharedInvite.delete_all
TeamProjectMember.delete_all
TeamProject.delete_all

IndividualTask.delete_all
IndividualProject.delete_all

UserItem.delete_all
Plant.delete_all

Interest.delete_all
Review.delete_all
Post.delete_all

Item.delete_all
User.delete_all

puts "Existing data cleared"

# --------------------------------------------------------
# CONSTANTS
# --------------------------------------------------------

POST_TITLES = [
  "Struggling to prioritise tasks effectively",
  "How do you stay focused during long work sessions?",
  "Best way to break down large projects?",
  "Any tips for managing weekly goals?",
  "Avoiding burnout while staying productive",
  "Tracking progress without micromanaging",
  "Staying consistent with daily habits",
  "Managing deadlines across multiple projects"
].freeze

POST_BODIES = [
  "I feel busy all day but not productive. Curious how others approach this.",
  "Looking for practical ways to stay focused without burning out.",
  "Large tasks keep getting delayed — how do you split them effectively?",
  "Weekly planning feels overwhelming. What systems actually work?",
  "Trying to balance output and wellbeing. Any advice?",
  "How do you track progress without checking things every hour?",
  "Motivation comes and goes — what helps with consistency?",
  "Deadlines keep colliding. How do you stay organised?"
].freeze

ADMIN_REPLY_BODIES = [
  "Thanks for raising this — it's a common challenge. Start by clarifying priorities, breaking work into smaller steps, and reviewing progress regularly.",
  "A good first step is reducing the number of active priorities. Focus on one meaningful outcome at a time and make progress visible.",
  "Try breaking the work into the smallest next action possible. Once the first step feels easy, momentum usually follows.",
  "Consistency tends to improve when you lower the barrier to starting. Short, repeatable habits beat perfect plans."
].freeze

REVIEWER_NAMES = [
  "Alex Morgan",
  "Jamie Patel",
  "Chris Thompson",
  "Taylor Nguyen",
  "Sam Wilson",
  "Jordan Ahmed",
  "Riley Brooks",
  "Priya Shah",
  "Daniel Kowalski",
  "Amelia Carter"
].freeze

REVIEW_BODIES = [
  "This tool helped me structure my workdays much more clearly.",
  "I'm far more consistent with my tasks since using this.",
  "Simple to use, but genuinely effective for staying on track.",
  "Great balance between flexibility and structure.",
  "Useful for keeping priorities visible without feeling overwhelming.",
  "Helped me stay focused during busy weeks."
].freeze

FIRST_NAMES = %w[
  Alex Jamie Sam Jordan Taylor Morgan Riley Casey Avery Quinn
  Priya Daniel Amelia Chris Sophie Leo Mia Noah Emma Lucas
].freeze

LAST_NAMES = %w[
  Brown Patel Nguyen Wilson Carter Thompson Reyes Kim Hughes Sullivan
  Shah Ahmed Brooks Turner Evans Murphy Reed Cooper Bailey Foster
].freeze

TEAM_PROJECT_NAMES = [
  "Launch Student Productivity Challenge",
  "Wellbeing Week Planning",
  "Peer Mentoring Rollout"
].freeze

TEAM_PROJECT_DESCRIPTIONS = [
  "Coordinate a collaborative student-facing initiative with shared tasks and milestones.",
  "Plan and deliver a week of events focused on sustainable productivity and wellbeing.",
  "Create a lightweight mentoring structure with resources, onboarding, and feedback loops."
].freeze

INDIVIDUAL_PROJECT_NAMES = [
  "Personal Study Sprint",
  "Dissertation Planning",
  "Weekly Habit Reset",
  "Portfolio Improvement",
  "Exam Revision Tracker"
].freeze

TASK_NAMES = [
  "Define success criteria",
  "Draft first outline",
  "Review current priorities",
  "Schedule focused work block",
  "Prepare weekly check-in",
  "Create progress update",
  "Research best examples",
  "Tidy backlog",
  "Complete first milestone",
  "Ask for feedback"
].freeze

SHARED_INVITE_MESSAGES = [
  "You've been invited to join the team project \"%{project_name}\".",
  "A team has shared \"%{project_name}\" with you.",
  "New collaboration invite: \"%{project_name}\" is waiting for you."
].freeze

BASE_ITEMS_DATA = [
  { name: "Daisy Seed",          category: "plant", description: "Small flower seed",        price: 0,   image_url: "images/plants/daisy_seed.webp" },
  { name: "Square Pot",          category: "pot",   description: "Modern square pot",        price: 0,   image_url: "images/pots/square_default.webp" }
].freeze

EXTRA_ITEMS_DATA = [
  { name: "Cactus Seed",         category: "plant", description: "Cactus seed",              price: 60,  image_url: "images/plants/cactus_seed.webp" },
  { name: "Marigold Seed",       category: "plant", description: "Marigold seed",            price: 120, image_url: "images/plants/marigold_seed.webp" },
  { name: "Hyacinth Seed",       category: "plant", description: "Hyacinth seed",            price: 180, image_url: "images/plants/hyacinth_seed.webp" },
  { name: "Blue Square Pot",     category: "pot",   description: "Blue square pot",          price: 40,  image_url: "images/pots/square_blue.webp" },
  { name: "Green Square Pot",    category: "pot",   description: "Green square pot",         price: 40,  image_url: "images/pots/square_green.webp" },
  { name: "Purple Square Pot",   category: "pot",   description: "Purple square pot",        price: 40,  image_url: "images/pots/square_purple.webp" },
  { name: "Red Square Pot",      category: "pot",   description: "Red square pot",           price: 40,  image_url: "images/pots/square_red.webp" },
  { name: "Yellow Square Pot",   category: "pot",   description: "Yellow square pot",        price: 40,  image_url: "images/pots/square_yellow.webp" },
  { name: "Triangle Pot",        category: "pot",   description: "Stylish triangle pot",     price: 60,  image_url: "images/pots/triangle_default.webp" },
  { name: "Blue Triangle Pot",   category: "pot",   description: "Blue triangle pot",        price: 100, image_url: "images/pots/triangle_blue.webp" },
  { name: "Green Triangle Pot",  category: "pot",   description: "Green triangle pot",       price: 100, image_url: "images/pots/triangle_green.webp" },
  { name: "Purple Triangle Pot", category: "pot",   description: "Purple triangle pot",      price: 100, image_url: "images/pots/triangle_purple.webp" },
  { name: "Red Triangle Pot",    category: "pot",   description: "Red triangle pot",         price: 100, image_url: "images/pots/triangle_red.webp" },
  { name: "Yellow Triangle Pot", category: "pot",   description: "Yellow triangle pot",      price: 100, image_url: "images/pots/triangle_yellow.webp" },
  { name: "Potion shaped Pot",   category: "pot",   description: "Unique potion-shaped pot", price: 200, image_url: "images/pots/potion_default.webp" },
  { name: "Blue Potion Pot",     category: "pot",   description: "Blue potion-shaped pot",   price: 240, image_url: "images/pots/potion_blue.webp" },
  { name: "Green Potion Pot",    category: "pot",   description: "Green potion-shaped pot",  price: 240, image_url: "images/pots/potion_green.webp" },
  { name: "Purple Potion Pot",   category: "pot",   description: "Purple potion-shaped pot", price: 240, image_url: "images/pots/potion_purple.webp" },
  { name: "Red Potion Pot",      category: "pot",   description: "Red potion-shaped pot",    price: 240, image_url: "images/pots/potion_red.webp" },
  { name: "Yellow Potion Pot",   category: "pot",   description: "Yellow potion-shaped pot", price: 240, image_url: "images/pots/potion_yellow.webp" }
].freeze

DIFFICULTIES = %w[easy medium hard].freeze

utm_sources = ["Instagram", "YouTube", "TikTok", "Direct", "The Diamond - Study Rooms"].freeze
utm_mediums = {
  "Instagram" => ["Social Media", "Sponsorship"],
  "YouTube" => ["Social Media", "Sponsorship"],
  "TikTok" => ["Social Media", "Sponsorship"],
  "Direct" => ["Direct"],
  "The Diamond - Study Rooms" => ["Flyer", "Sponsorship", "Word of Mouth"]
}.freeze

ip_locations = [
  ["34.21.9.50", "United States", "Dulles"],
  ["34.106.208.213", "United States", "Salt Lake City"],
  ["34.94.159.140", "United States", "Los Angeles"],
  ["34.130.107.20", "Canada", "Toronto"],
  ["34.39.131.22", "Brazil", "Sao Paulo"],
  ["34.240.49.81", "Ireland", "Dublin"],
  ["35.242.177.6", "United Kingdom", "London"],
  ["13.36.154.207", "France", "Paris"],
  ["34.91.238.70", "Netherlands", "Amsterdam"],
  ["34.159.56.80", "Germany", "Frankfurt"],
  ["34.154.170.5", "Italy", "Milan"],
  ["35.228.243.201", "Finland", "Hamina"],
  ["13.246.114.251", "South Africa", "Cape Town"],
  ["15.184.48.78", "Bahrain", "Manama"],
  ["20.74.211.96", "United Arab Emirates", "Dubai"]
].freeze

TEAM_PROJECT_THEMES = %w[forest mixed tent office].freeze

# --------------------------------------------------------
# ITEMS
# --------------------------------------------------------

puts "Creating items..."

BASE_ITEMS_DATA.map do |attrs|
  Item.create!(
    **attrs,
    created_at: sample_time_within(days_back: 90),
    updated_at: Time.current
  )
end

EXTRA_ITEMS_DATA.map do |attrs|
  Item.create!(
    **attrs,
    created_at: sample_time_within(days_back: 90),
    updated_at: Time.current
  )
end

base_plant_item = Item.find_by(name: "Daisy Seed")
base_pot_item   = Item.find_by(name: "Square Pot")

extra_plant_items = Item.where("name LIKE ?", "%Seed").where.not(name: "Daisy Seed").to_a
extra_pot_items   = Item.where(category: "pot").where.not(name: "Square Pot").to_a

puts "Items created: #{Item.count}"

# --------------------------------------------------------
# USERS AND PLANTS
# --------------------------------------------------------

puts "Creating users and plants (for subscribers only)..."

admins = 2.times.map do |i|
  User.create!(
    email: "admin#{i + 1}@example.com",
    password: "Password@1234",
    first_name: "Admin",
    last_name: "#{i + 1}",
    was_subscriber: false,
    role: "admin",
    points: rand(150..400),
    created_at: sample_time_within(days_back: 120),
    updated_at: Time.current
  )
end

reporters = 3.times.map do |i|
  User.create!(
    email: "reporter#{i + 1}@example.com",
    password: "Password@1234",
    first_name: "Product",
    last_name: "Reporter #{i + 1}",
    was_subscriber: false,
    role: "reporter",
    points: rand(80..220),
    created_at: sample_time_within(days_back: 120),
    updated_at: Time.current
  )
end

members = 8.times.map do |i|
  User.create!(
    email: "member#{i + 1}@example.com",
    password: "Password@1234",
    first_name: FIRST_NAMES.sample,
    last_name: LAST_NAMES.sample,
    role: "subscriber",
    was_subscriber: true,
    points: rand(20..180),
    created_at: sample_time_within(days_back: 120),
    updated_at: Time.current
  )
end

subscribers = 8.times.map do |i|
  User.create!(
    email: "subscriber#{i + 1}@example.com",
    password: "Password@1234",
    first_name: FIRST_NAMES.sample,
    last_name: LAST_NAMES.sample,
    role: "subscriber",
    was_subscriber: true,
    points: rand(0..120),
    created_at: sample_time_within(days_back: 120),
    updated_at: Time.current
  )
end

all_users = admins + reporters + members + subscribers

puts "Users created: #{User.count}"
puts "Plants created: #{Plant.count}"

# --------------------------------------------------------
# USER ITEMS
# --------------------------------------------------------

puts "Creating user items..."

subscribers.each do |subscriber|
  (extra_plant_items.sample(rand(0..1)) + extra_pot_items.sample(rand(0..2))).each do |item|
    UserItem.create!(
      user: subscriber,
      item: item,
      purchased_at: sample_time_within(days_back: 60),
      created_at: sample_time_within(days_back: 60),
      updated_at: Time.current
    )
  end
end

puts "User items created: #{UserItem.count}"

# --------------------------------------------------------
# INDIVIDUAL PROJECTS + TASKS
# --------------------------------------------------------

puts "Creating individual projects and tasks..."

(members + subscribers).each do |user|
  project = user.individual_project || user.create_individual_project!

  project.update!(
    name: INDIVIDUAL_PROJECT_NAMES.sample,
    created_at: sample_time_within(days_back: 60),
    updated_at: Time.current
  )

  rand(3..50).times do
    difficulty = DIFFICULTIES.sample
    due_date = future_time_within(days_forward: 30)

    IndividualTask.create!(
      individual_project: project,
      name: TASK_NAMES.sample,
      description: "A focused step toward progress on #{project.name.downcase}.",
      due_date: due_date,
      reminder_date: due_date - rand(1..3).days,
      status_complete: task_status_for_due_date(due_date),
      difficulty: difficulty,
      read: [true, false].sample,
      points: difficulty_points(difficulty),
      created_at: sample_time_within(days_back: 30),
      updated_at: Time.current
    )
  end

  IndividualTask.find_or_create_by!(
    individual_project: project,
    name: 'Demo AI Task'
  ) do |task|
    task.description = 'This is a pre-seeded demo task used to show the AI task breakdown ' \
                   'fallback when the external AI service is unavailable.'
    task.due_date = 1.week.from_now
    task.reminder_date = nil
    task.status_complete = false
    task.difficulty = 'easy'
    task.read = false
    task.points = 20
    task.created_at = Time.current
    task.updated_at = Time.current
  end
end

puts "Individual projects created: #{IndividualProject.count}"
puts "Individual tasks created: #{IndividualTask.count}"

# --------------------------------------------------------
# TEAM PROJECTS + MEMBERS + TASKS + ASSIGNMENTS
# --------------------------------------------------------

puts "Creating team projects..."

team_projects = 3.times.map do |i|
  theme = TEAM_PROJECT_THEMES.sample

  TeamProject.create!(
    name: TEAM_PROJECT_NAMES[i],
    description: TEAM_PROJECT_DESCRIPTIONS[i],
    leaderboard_visible: [true, true, false].sample,
    image_path: "#{theme}-theme.jpg",
    created_at: sample_time_within(days_back: 90),
    updated_at: Time.current
  )
end

team_projects.each_with_index do |project, index|
  project_members = subscribers.sample(rand(4..7))
  lead_user = project_members.sample

  project_memberships = project_members.map do |user|
    role = user == lead_user ? "team_lead" : "team_member"

    TeamProjectMember.create!(
      team_project: project,
      user: user,
      role: role,
      points: rand(0..100),
      joined_at: sample_time_within(days_back: 60),
      leaderboard_visibility: [true, true, false].sample,
      created_at: sample_time_within(days_back: 60),
      updated_at: Time.current
    )
  end

  rand(4..7).times do
    difficulty = DIFFICULTIES.sample
    due_date = future_time_within(days_forward: 45)

    task = TeamProjectTask.create!(
      team_project: project,
      name: TASK_NAMES.sample,
      description: "Collaborative task for #{project.name.downcase}.",
      due_date: due_date,
      reminder_date: due_date - rand(1..4).days,
      status_complete: task_status_for_due_date(due_date),
      difficulty: difficulty,
      points: difficulty_points(difficulty),
      read: [true, false].sample,
      created_at: sample_time_within(days_back: 30),
      updated_at: Time.current
    )

    project_memberships.sample(rand(1..2)).each do |membership|
      TeamTaskAssignment.create!(
        team_project_task: task,
        team_project_member: membership,
        created_at: sample_time_within(days_back: 20),
        updated_at: Time.current
      )
    end
  end
end

puts "Team projects created: #{TeamProject.count}"
puts "Team project members created: #{TeamProjectMember.count}"
puts "Team project tasks created: #{TeamProjectTask.count}"
puts "Team task assignments created: #{TeamTaskAssignment.count}"

# --------------------------------------------------------
# SHARED INVITES + NOTIFICATIONS
# --------------------------------------------------------

puts "Creating shared invites and notifications..."

team_projects.each do |project|
  current_member_user_ids = TeamProjectMember.where(team_project: project).pluck(:user_id)

  invite_candidates = (members + subscribers)
    .uniq
    .reject { |user| current_member_user_ids.include?(user.id) }

  invite_candidates.sample(rand(1..3)).each do |user|
    invite = SharedInvite.create!(
      email: user.email,
      team_project: project,
      created_at: sample_time_within(days_back: 20),
      updated_at: Time.current
    )

    Notification.create!(
      user: user,
      shared_invite: invite,
      message: format(
        SHARED_INVITE_MESSAGES.sample,
        project_name: project.name
      ),
      read: [false, false, false, true].sample,
      created_at: invite.created_at,
      updated_at: Time.current
    )
  end
end

puts "Shared invites created: #{SharedInvite.count}"
puts "Notifications created: #{Notification.count}"

# --------------------------------------------------------
# RADAR CATEGORIES + RATINGS
# --------------------------------------------------------

puts "Creating radar categories and ratings..."

RADAR_CATEGORY_NAMES = [
  "Communication",
  "Planning",
  "Ownership",
  "Execution",
  "Collaboration",
  "Wellbeing"
].freeze

team_projects.each do |project|
  categories = RADAR_CATEGORY_NAMES.sample(4).map do |category_name|
    RadarCategory.create!(
      team_project: project,
      name: category_name,
      created_at: sample_time_within(days_back: 30),
      updated_at: Time.current
    )
  end

  memberships = TeamProjectMember.where(team_project: project)

  categories.each do |category|
    memberships.each do |membership|
      RadarRating.create!(
        radar_category: category,
        team_project: project,
        team_project_member: membership,
        category_rating: rand(2..5),
        created_at: sample_time_within(days_back: 20),
        updated_at: Time.current
      )
    end
  end
end

puts "Radar categories created: #{RadarCategory.count}"
puts "Radar ratings created: #{RadarRating.count}"

# --------------------------------------------------------
# POSTS + ADMIN REPLIES
# --------------------------------------------------------

puts "Creating posts..."

authors = members + reporters + subscribers
posts = []

authors.each do |_user|
  rand(1..2).times do
    posts << Post.create!(
      title: POST_TITLES.sample,
      body: POST_BODIES.sample,
      answer_by_admin: false,
      hidden: [false, false, false, true].sample,
      interest_count: rand(0..12),
      parent_id: nil,
      created_at: sample_time_within(days_back: 60),
      updated_at: Time.current
    )
  end
end

puts "Base posts created: #{posts.count}"

puts "Creating admin replies..."

posts.each do |original|
  create_post_reply(
    original,
    body: ADMIN_REPLY_BODIES.sample
  )
end

puts "Total posts including replies: #{Post.count}"

# --------------------------------------------------------
# REVIEWS
# --------------------------------------------------------

puts "Creating reviews..."

(1..3).each do |idx|
  Review.create!(
    rating: rand(4..5),
    body: REVIEW_BODIES.sample,
    review_index: idx,
    name: REVIEWER_NAMES[idx - 1],
    positive_interest_count: rand(8..30),
    negative_interest_count: rand(0..5),
    hidden: false,
    created_at: sample_time_within(days_back: 90),
    updated_at: Time.current
  )
end

10.times do
  Review.create!(
    rating: rand(3..5),
    body: REVIEW_BODIES.sample,
    review_index: nil,
    name: REVIEWER_NAMES.sample,
    positive_interest_count: rand(0..20),
    negative_interest_count: rand(0..6),
    hidden: [false, false, false, true].sample,
    created_at: sample_time_within(days_back: 90),
    updated_at: Time.current
  )
end

puts "Reviews created: #{Review.count}"

# --------------------------------------------------------
# INTERESTS, AHOY VISITS AND AHOY EVENTS
# --------------------------------------------------------

if defined?(Ahoy::Visit) && defined?(Ahoy::Event) && defined?(Metrics::LandingPageMetrics)
  puts "Creating Interests, Ahoy Visits and Ahoy Events..."

  post_ids = Post.where(parent_id: nil).pluck(:id)

  non_registration_event_names = Metrics::LandingPageMetrics::AHOY_EVENT_NAMES.values
  non_registration_event_names.delete(Metrics::LandingPageMetrics::AHOY_EVENT_NAMES[:REGISTERED_INTEREST])
  non_registration_event_names.delete(Metrics::LandingPageMetrics::AHOY_EVENT_NAMES[:SHARED_FEATURE_PREFIX])

  puts "Creating Ahoy Visits without registrations..."

  10.times do
    utm_source = utm_sources.sample
    utm_medium = utm_mediums[utm_source].sample
    location = ip_locations.sample
    started_at = sample_time_within(days_back: 30)

    visit = Ahoy::Visit.create!(
      visit_token: SecureRandom.uuid,
      visitor_token: SecureRandom.uuid,
      user_id: all_users.sample.id,
      ip: location[0],
      country: location[1],
      city: location[2],
      browser: %w[Chrome Safari Firefox Edge].sample,
      os: %w[macOS Windows iOS Android Linux].sample,
      device_type: %w[Desktop Mobile Tablet].sample,
      landing_page: ["/", "/pricing", "/community", "/features"].sample,
      utm_source: utm_source,
      utm_medium: utm_medium,
      utm_campaign: ["spring-launch", "student-growth", "creator-partner"].sample,
      started_at: started_at
    )

    rand(0..15).times do
      name = non_registration_event_names.sample
      properties = {}

      if name == Metrics::LandingPageMetrics::AHOY_EVENT_NAMES[:VISITED_LANDING_PAGE]
        properties["ip"] = location[0]
        properties["country"] = location[1]
        properties["city"] = location[2]
      elsif name == Metrics::LandingPageMetrics::AHOY_EVENT_NAMES[:VIEWED_QUESTION_PREFIX]
        post_id = post_ids.sample
        properties["post_id"] = post_id
        name = "#{name} - Post #{post_id}"
      end

      Ahoy::Event.create!(
        visit_id: visit.id,
        user_id: visit.user_id,
        name: name,
        time: started_at + rand(0..30).minutes,
        properties: properties
      )
    end
  end

  puts "Creating Interests and Ahoy Visits with registrations..."

  5.times do |visit_index|
    utm_source = utm_sources.sample
    utm_medium = utm_mediums[utm_source].sample
    location = ip_locations.sample
    started_at = sample_time_within(days_back: 30)

    visit = Ahoy::Visit.create!(
      visit_token: SecureRandom.uuid,
      visitor_token: SecureRandom.uuid,
      user_id: nil,
      ip: location[0],
      country: location[1],
      city: location[2],
      browser: %w[Chrome Safari Firefox Edge].sample,
      os: %w[macOS Windows iOS Android Linux].sample,
      device_type: %w[Desktop Mobile Tablet].sample,
      landing_page: ["/", "/pricing", "/community", "/features"].sample,
      utm_source: utm_source,
      utm_medium: utm_medium,
      utm_campaign: ["spring-launch", "student-growth", "creator-partner"].sample,
      started_at: started_at
    )

    rand(0..14).times do
      name = non_registration_event_names.sample
      properties = {}

      if name == Metrics::LandingPageMetrics::AHOY_EVENT_NAMES[:VISITED_LANDING_PAGE]
        properties["ip"] = location[0]
        properties["country"] = location[1]
        properties["city"] = location[2]
      elsif name == Metrics::LandingPageMetrics::AHOY_EVENT_NAMES[:VIEWED_QUESTION_PREFIX]
        post_id = post_ids.sample
        properties["post_id"] = post_id
        name = "#{name} - Post #{post_id}"
      end

      Ahoy::Event.create!(
        visit_id: visit.id,
        user_id: nil,
        name: name,
        time: started_at + rand(0..30).minutes,
        properties: properties
      )
    end

    unique_number = "#{visit_index}#{rand(100..999)}"
    registration_email = "interested.user#{unique_number}@example.com"

    Interest.create!(
      name: "Interested User ##{unique_number}",
      email: registration_email,
      created_at: started_at + 33.minutes,
      updated_at: started_at + 33.minutes
    )

    Ahoy::Event.create!(
      visit_id: visit.id,
      user_id: nil,
      name: Metrics::LandingPageMetrics::AHOY_EVENT_NAMES[:REGISTERED_INTEREST],
      time: started_at + 35.minutes,
      properties: {
        "ip" => location[0],
        "country" => location[1],
        "city" => location[2],
        "registration_email" => registration_email
      }
    )
  end

  if respond_to?(:update_question_interests)
    puts "Updating question interests from Metrics::LandingPageMetrics..."
    PostsService.update_question_interests(Post.where(answer_by_admin: false))
  end

  puts "Interests created: #{Interest.count}"
  puts "Ahoy Visits created: #{Ahoy::Visit.count}"
  puts "Ahoy Events created: #{Ahoy::Event.count}"
else
  puts "Skipping landing page metric seeds because Ahoy or Metrics::LandingPageMetrics is not available"
end

# --------------------------------------------------------
# SUMMARY
# --------------------------------------------------------

puts "----------------------------------------"
puts "Users: #{User.count}"
puts "Items: #{Item.count}"
puts "User Items: #{UserItem.count}"
puts "Plants: #{Plant.count}"
puts "Individual Projects: #{IndividualProject.count}"
puts "Individual Tasks: #{IndividualTask.count}"
puts "Team Projects: #{TeamProject.count}"
puts "Team Members: #{TeamProjectMember.count}"
puts "Team Tasks: #{TeamProjectTask.count}"
puts "Task Assignments: #{TeamTaskAssignment.count}"
puts "Shared Invites: #{SharedInvite.count}"
puts "Notifications: #{Notification.count}"
puts "Radar Categories: #{RadarCategory.count}"
puts "Radar Ratings: #{RadarRating.count}"
puts "Posts: #{Post.count}"
puts "Reviews: #{Review.count}"
puts "Interests: #{Interest.count}"
puts "Ahoy Visits: #{defined?(Ahoy::Visit) ? Ahoy::Visit.count : 0}"
puts "Ahoy Events: #{defined?(Ahoy::Event) ? Ahoy::Event.count : 0}"
puts "----------------------------------------"
