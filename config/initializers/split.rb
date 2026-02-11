require 'split'
require 'split/dashboard'

Split.configure do |config|
  config.db_failover = true
  config.db_failover_on_db_error = proc { |error| Rails.logger.error(error.message) }
  config.allow_multiple_experiments = true
  config.enabled = true

  config.persistence = :cookie
  config.persistence_cookie_length = 2592000

  config.dashboard_pagination_default_per_page = 100
  config.cache = true

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
    },
    "header_style" => {
      alternatives: ["minimal", "standard", "detailed"],
      goals: ["user_engagement"]
    },
    "sidebar_layout" => {
      alternatives: ["collapsed", "expanded", "auto"],
      goals: ["navigation_usage"]
    },
    "notification_timing" => {
      alternatives: ["immediate", "delayed_5s", "delayed_10s"],
      goals: ["notification_clicked"]
    },
    "search_placeholder" => {
      alternatives: ["search_todos", "find_tasks", "quick_search"],
      goals: ["search_used"]
    },
    "loading_animation" => {
      alternatives: ["spinner", "dots", "progress_bar"],
      goals: ["user_retention"]
    },
    "error_message_style" => {
      alternatives: ["brief", "detailed", "friendly"],
      goals: ["error_recovery"]
    },
    "pagination_size" => {
      alternatives: ["5", "10", "15"],
      goals: ["page_views"]
    },
    "theme_switcher" => {
      alternatives: ["button", "dropdown", "toggle"],
      goals: ["theme_changed"]
    },
    "footer_content" => {
      alternatives: ["minimal", "links", "social"],
      goals: ["footer_clicks"]
    },
    "sort_default" => {
      alternatives: ["created_date", "priority", "alphabetical"],
      goals: ["sort_changed"]
    },
    "bulk_actions" => {
      alternatives: ["checkbox", "selection", "menu"],
      goals: ["bulk_operation"]
    },
    "todo_preview" => {
      alternatives: ["hover", "click", "sidebar"],
      goals: ["preview_used"]
    },
    "keyboard_shortcuts" => {
      alternatives: ["enabled", "disabled", "help_tooltip"],
      goals: ["shortcut_used"]
    },
    "auto_save" => {
      alternatives: ["immediate", "3_seconds", "5_seconds"],
      goals: ["data_saved"]
    },
    "attachment_display" => {
      alternatives: ["thumbnails", "list", "grid"],
      goals: ["attachment_viewed"]
    },
    "reminder_frequency" => {
      alternatives: ["daily", "weekly", "monthly"],
      goals: ["reminder_acted"]
    },
    "export_format" => {
      alternatives: ["json", "csv", "pdf"],
      goals: ["export_completed"]
    },
    "collaboration_ui" => {
      alternatives: ["avatars", "initials", "names"],
      goals: ["collaboration_started"]
    },
    "mobile_navigation" => {
      alternatives: ["bottom_tabs", "hamburger", "swipe"],
      goals: ["mobile_navigation"]
    },
    "onboarding_flow" => {
      alternatives: ["tour", "checklist", "video"],
      goals: ["onboarding_completed"]
    },
    "performance_metrics" => {
      alternatives: ["hidden", "summary", "detailed"],
      goals: ["metrics_viewed"]
    },
    "accessibility_mode" => {
      alternatives: ["standard", "high_contrast", "large_text"],
      goals: ["accessibility_used"]
    },
    "data_visualization" => {
      alternatives: ["charts", "graphs", "tables"],
      goals: ["data_explored"]
    }
  }
end

Split::Dashboard.use Rack::Auth::Basic do |username, password|
  username == 'admin' && password == 'secret'
end
