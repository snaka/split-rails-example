module SplitHelper
  include Split::Helper

  def layout_variant
    ab_test(:todo_list_layout)
  end

  def button_color_variant
    ab_test(:button_color)
  end

  def priority_label_variant
    ab_test(:priority_labels)
  end

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