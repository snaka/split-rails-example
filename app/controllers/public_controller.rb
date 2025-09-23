class PublicController < ApplicationController
  include Split::Helper

  def about
    # Test header_style experiment
    @header_style = ab_test(:header_style)

    # Test theme_switcher experiment
    @theme_switcher = ab_test(:theme_switcher)

    # Track goal when user engages
    ab_finished(:user_engagement) if params[:engage] == 'true'
  end

  def features
    # Test sidebar_layout experiment
    @sidebar_layout = ab_test(:sidebar_layout)

    # Test data_visualization experiment
    @data_visualization = ab_test(:data_visualization)

    # Track goal when user explores data
    ab_finished(:data_explored) if params[:explore] == 'true'
  end

  def pricing
    # Test button_color experiment (existing)
    @button_color = ab_test(:button_color)

    # Test footer_content experiment
    @footer_content = ab_test(:footer_content)

    # Track goal when footer is clicked
    ab_finished(:footer_clicks) if params[:footer_action] == 'true'
  end

  def contact
    # Test error_message_style experiment
    @error_message_style = ab_test(:error_message_style)

    # Test notification_timing experiment
    @notification_timing = ab_test(:notification_timing)
  end

  def contact_submit
    # Test error_message_style for validation errors
    @error_message_style = ab_test(:error_message_style)

    if params[:name].present? && params[:email].present? && params[:message].present?
      # Track notification goal
      ab_finished(:notification_clicked)
      redirect_to contact_path, notice: "Thank you for your message!"
    else
      # Track error recovery goal
      ab_finished(:error_recovery)
      @errors = []
      @errors << "Name is required" if params[:name].blank?
      @errors << "Email is required" if params[:email].blank?
      @errors << "Message is required" if params[:message].blank?
      render :contact, status: :unprocessable_entity
    end
  end

  def help
    # Test search_placeholder experiment
    @search_placeholder = ab_test(:search_placeholder)

    # Test keyboard_shortcuts experiment
    @keyboard_shortcuts = ab_test(:keyboard_shortcuts)

    # Test accessibility_mode experiment
    @accessibility_mode = ab_test(:accessibility_mode)

    # Track goals
    ab_finished(:search_used) if params[:search].present?
    ab_finished(:shortcut_used) if params[:shortcut] == 'true'
    ab_finished(:accessibility_used) if params[:accessibility] == 'true'
  end

  def demo
    # Test multiple experiments for demo interactions
    @loading_animation = ab_test(:loading_animation)
    @pagination_size = ab_test(:pagination_size)
    @sort_default = ab_test(:sort_default)
    @bulk_actions = ab_test(:bulk_actions)
    @todo_preview = ab_test(:todo_preview)
    @auto_save = ab_test(:auto_save)
    @attachment_display = ab_test(:attachment_display)
    @mobile_navigation = ab_test(:mobile_navigation)
    @onboarding_flow = ab_test(:onboarding_flow)
    @performance_metrics = ab_test(:performance_metrics)
    @reminder_frequency = ab_test(:reminder_frequency)
    @export_format = ab_test(:export_format)
    @collaboration_ui = ab_test(:collaboration_ui)

    # Sample demo data
    @demo_todos = [
      { id: 1, title: "Learn Ruby on Rails", priority: 1, completed: false },
      { id: 2, title: "Build Todo App", priority: 2, completed: true },
      { id: 3, title: "Deploy to Production", priority: 1, completed: false },
      { id: 4, title: "Write Documentation", priority: 3, completed: false },
      { id: 5, title: "Add A/B Testing", priority: 2, completed: true }
    ]

    # Apply pagination based on experiment
    @page_size = @pagination_size.to_i
    @current_page = (params[:page] || 1).to_i
    start_index = (@current_page - 1) * @page_size
    @paginated_todos = @demo_todos[start_index, @page_size] || []
    @total_pages = (@demo_todos.length.to_f / @page_size).ceil
  end

  def demo_action
    # Track various goals based on action type
    case params[:action_type]
    when 'page_view'
      ab_finished(:page_views)
    when 'sort_change'
      ab_finished(:sort_changed)
    when 'bulk_operation'
      ab_finished(:bulk_operation)
    when 'preview_used'
      ab_finished(:preview_used)
    when 'data_saved'
      ab_finished(:data_saved)
    when 'attachment_viewed'
      ab_finished(:attachment_viewed)
    when 'reminder_acted'
      ab_finished(:reminder_acted)
    when 'export_completed'
      ab_finished(:export_completed)
    when 'collaboration_started'
      ab_finished(:collaboration_started)
    when 'mobile_navigation'
      ab_finished(:mobile_navigation)
    when 'onboarding_completed'
      ab_finished(:onboarding_completed)
    when 'metrics_viewed'
      ab_finished(:metrics_viewed)
    when 'navigation_usage'
      ab_finished(:navigation_usage)
    when 'user_retention'
      ab_finished(:user_retention)
    when 'theme_changed'
      ab_finished(:theme_changed)
    end

    render json: { status: 'success', action: params[:action_type] }
  end
end