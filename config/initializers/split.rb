require 'split'
require 'split/dashboard'

Split.configure do |config|
  config.db_failover = true
  config.db_failover_on_db_error = proc { |error| Rails.logger.error(error.message) }
  config.allow_multiple_experiments = true
  config.enabled = true

  config.persistence = :cookie
  config.persistence_cookie_length = 2592000

  config.experiments = {
    "todo_list_layout" => {
      alternatives: ["card_view", "list_view", "grid_view"],
      goals: ["todo_completed", "todo_created"]
    },
    "button_color" => {
      alternatives: ["blue", "green", "purple"],
      goals: ["todo_completed"]
    },
    "priority_labels" => {
      alternatives: ["numeric", "text_labels", "color_coded"],
      goals: ["todo_created", "todo_completed"]
    }
  }
end

Split::Dashboard.use Rack::Auth::Basic do |username, password|
  username == 'admin' && password == 'secret'
end