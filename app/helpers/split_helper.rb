module SplitHelper
  include Split::Helper

  # Original experiments
  def layout_variant
    ab_test(:todo_list_layout)
  end

  def button_color_variant
    ab_test(:button_color)
  end

  def priority_label_variant
    ab_test(:priority_labels)
  end

  # New experiment helpers
  def header_style_variant
    ab_test(:header_style)
  end

  def sidebar_layout_variant
    ab_test(:sidebar_layout)
  end

  def notification_timing_variant
    ab_test(:notification_timing)
  end

  def search_placeholder_variant
    ab_test(:search_placeholder)
  end

  def loading_animation_variant
    ab_test(:loading_animation)
  end

  def error_message_style_variant
    ab_test(:error_message_style)
  end

  def theme_switcher_variant
    ab_test(:theme_switcher)
  end

  def footer_content_variant
    ab_test(:footer_content)
  end

  # Style helper methods
  def button_color_class
    case button_color_variant
    when "blue"
      "bg-blue-500 hover:bg-blue-700 text-white"
    when "green"
      "bg-green-500 hover:bg-green-700 text-white"
    when "purple"
      "bg-purple-500 hover:bg-purple-700 text-white"
    else
      "bg-blue-500 hover:bg-blue-700 text-white"
    end
  end

  def header_style_class
    case header_style_variant
    when "minimal"
      "py-2 text-lg font-medium"
    when "standard"
      "py-4 text-xl font-semibold border-b"
    when "detailed"
      "py-6 text-2xl font-bold border-b-2 shadow-sm"
    else
      "py-4 text-xl font-semibold border-b"
    end
  end

  def sidebar_layout_class
    case sidebar_layout_variant
    when "collapsed"
      "w-16 transition-all duration-300"
    when "expanded"
      "w-64 transition-all duration-300"
    when "auto"
      "w-48 lg:w-64 transition-all duration-300"
    else
      "w-48 lg:w-64 transition-all duration-300"
    end
  end

  def loading_animation_html
    case loading_animation_variant
    when "spinner"
      "<div class='animate-spin rounded-full h-8 w-8 border-b-2 border-blue-500'></div>".html_safe
    when "dots"
      "<div class='flex space-x-1'><div class='animate-pulse bg-blue-500 rounded-full h-2 w-2'></div><div class='animate-pulse bg-blue-500 rounded-full h-2 w-2' style='animation-delay: 0.1s'></div><div class='animate-pulse bg-blue-500 rounded-full h-2 w-2' style='animation-delay: 0.2s'></div></div>".html_safe
    when "progress_bar"
      "<div class='w-full bg-gray-200 rounded-full h-2'><div class='bg-blue-500 h-2 rounded-full animate-pulse' style='width: 60%'></div></div>".html_safe
    else
      "<div class='animate-spin rounded-full h-8 w-8 border-b-2 border-blue-500'></div>".html_safe
    end
  end

  def search_placeholder_text
    case search_placeholder_variant
    when "search_todos"
      "Search todos..."
    when "find_tasks"
      "Find tasks..."
    when "quick_search"
      "Quick search..."
    else
      "Search..."
    end
  end

  def error_message_class
    case error_message_style_variant
    when "brief"
      "text-red-600 text-sm"
    when "detailed"
      "text-red-700 bg-red-50 p-3 rounded border border-red-200"
    when "friendly"
      "text-red-600 bg-red-50 p-3 rounded-lg border-l-4 border-red-400"
    else
      "text-red-600 text-sm"
    end
  end

  def theme_switcher_html
    case theme_switcher_variant
    when "button"
      "<button class='px-3 py-1 bg-gray-200 rounded hover:bg-gray-300'>Theme</button>".html_safe
    when "dropdown"
      "<select class='px-2 py-1 border rounded'><option>Light</option><option>Dark</option></select>".html_safe
    when "toggle"
      "<label class='flex items-center cursor-pointer'><input type='checkbox' class='sr-only'><div class='relative'><div class='block bg-gray-600 w-14 h-8 rounded-full'></div><div class='dot absolute left-1 top-1 bg-white w-6 h-6 rounded-full transition'></div></div></label>".html_safe
    else
      "<button class='px-3 py-1 bg-gray-200 rounded hover:bg-gray-300'>Theme</button>".html_safe
    end
  end

  def footer_content_html
    case footer_content_variant
    when "minimal"
      "<p class='text-gray-600'>&copy; 2023 Todo App</p>".html_safe
    when "links"
      "<div class='flex space-x-4'><a href='#' class='text-gray-600 hover:text-gray-800'>About</a><a href='#' class='text-gray-600 hover:text-gray-800'>Contact</a><a href='#' class='text-gray-600 hover:text-gray-800'>Privacy</a></div>".html_safe
    when "social"
      "<div class='flex space-x-4'><a href='#' class='text-gray-600 hover:text-gray-800'>Twitter</a><a href='#' class='text-gray-600 hover:text-gray-800'>GitHub</a><a href='#' class='text-gray-600 hover:text-gray-800'>LinkedIn</a></div>".html_safe
    else
      "<p class='text-gray-600'>&copy; 2023 Todo App</p>".html_safe
    end
  end

  def priority_display(priority)
    case priority_label_variant
    when "numeric"
      priority.to_s
    when "text_labels"
      priority_text_label(priority)
    when "color_coded"
      priority_color_badge(priority)
    else
      priority.to_s
    end
  end

  private

  def priority_text_label(priority)
    labels = {
      1 => "Critical",
      2 => "High",
      3 => "Medium",
      4 => "Low",
      5 => "Minimal"
    }
    labels[priority] || "Unknown"
  end

  def priority_color_badge(priority)
    colors = {
      1 => "red",
      2 => "orange",
      3 => "yellow",
      4 => "green",
      5 => "gray"
    }
    color = colors[priority] || "gray"
    "<span class='px-2 py-1 text-xs rounded-full bg-#{color}-200 text-#{color}-800'>P#{priority}</span>".html_safe
  end
end