#!/usr/bin/env ruby

require 'redis'
require 'json'
require 'securerandom'
require 'optparse'

class SplitTestDataGenerator
  def initialize(options = {})
    @redis = Redis.new(url: options[:redis_url] || 'redis://localhost:6379')
    @participants = options[:participants] || 10000
    @conversions_ratio = options[:conversions_ratio] || 0.1
    @experiments = load_experiments
    @verbose = options[:verbose] || false
  end

  def generate
    puts "Generating test data for Split A/B tests..."
    puts "Participants: #{@participants}"
    puts "Conversion ratio: #{(@conversions_ratio * 100).round(1)}%"
    puts "Experiments: #{@experiments.length}"
    puts "-" * 50

    @experiments.each do |experiment_name, config|
      puts "Processing experiment: #{experiment_name}" if @verbose
      generate_experiment_data(experiment_name, config)
    end

    puts "\nTest data generation completed!"
    print_summary
  end

  def clear_data
    puts "Clearing existing Split test data..."

    # Get all Split-related keys
    keys = @redis.keys('split:*')

    if keys.any?
      @redis.del(*keys)
      puts "Cleared #{keys.length} Split keys"
    else
      puts "No Split data found to clear"
    end
  end

  private

  def load_experiments
    {
      'todo_list_layout' => {
        alternatives: ['card_view', 'list_view', 'grid_view'],
        goals: ['todo_completed', 'todo_created']
      },
      'button_color' => {
        alternatives: ['blue', 'green', 'purple'],
        goals: ['todo_completed']
      },
      'priority_labels' => {
        alternatives: ['numeric', 'text_labels', 'color_coded'],
        goals: ['todo_created', 'todo_completed']
      },
      'header_style' => {
        alternatives: ['minimal', 'standard', 'detailed'],
        goals: ['user_engagement']
      },
      'sidebar_layout' => {
        alternatives: ['collapsed', 'expanded', 'auto'],
        goals: ['navigation_usage']
      },
      'notification_timing' => {
        alternatives: ['immediate', 'delayed_5s', 'delayed_10s'],
        goals: ['notification_clicked']
      },
      'search_placeholder' => {
        alternatives: ['search_todos', 'find_tasks', 'quick_search'],
        goals: ['search_used']
      },
      'loading_animation' => {
        alternatives: ['spinner', 'dots', 'progress_bar'],
        goals: ['user_retention']
      },
      'error_message_style' => {
        alternatives: ['brief', 'detailed', 'friendly'],
        goals: ['error_recovery']
      },
      'pagination_size' => {
        alternatives: ['5', '10', '15'],
        goals: ['page_views']
      },
      'theme_switcher' => {
        alternatives: ['button', 'dropdown', 'toggle'],
        goals: ['theme_changed']
      },
      'footer_content' => {
        alternatives: ['minimal', 'links', 'social'],
        goals: ['footer_clicks']
      },
      'sort_default' => {
        alternatives: ['created_date', 'priority', 'alphabetical'],
        goals: ['sort_changed']
      },
      'bulk_actions' => {
        alternatives: ['checkbox', 'selection', 'menu'],
        goals: ['bulk_operation']
      },
      'todo_preview' => {
        alternatives: ['hover', 'click', 'sidebar'],
        goals: ['preview_used']
      },
      'keyboard_shortcuts' => {
        alternatives: ['enabled', 'disabled', 'help_tooltip'],
        goals: ['shortcut_used']
      },
      'auto_save' => {
        alternatives: ['immediate', '3_seconds', '5_seconds'],
        goals: ['data_saved']
      },
      'attachment_display' => {
        alternatives: ['thumbnails', 'list', 'grid'],
        goals: ['attachment_viewed']
      },
      'reminder_frequency' => {
        alternatives: ['daily', 'weekly', 'monthly'],
        goals: ['reminder_acted']
      },
      'export_format' => {
        alternatives: ['json', 'csv', 'pdf'],
        goals: ['export_completed']
      },
      'collaboration_ui' => {
        alternatives: ['avatars', 'initials', 'names'],
        goals: ['collaboration_started']
      },
      'mobile_navigation' => {
        alternatives: ['bottom_tabs', 'hamburger', 'swipe'],
        goals: ['mobile_navigation']
      },
      'onboarding_flow' => {
        alternatives: ['tour', 'checklist', 'video'],
        goals: ['onboarding_completed']
      },
      'performance_metrics' => {
        alternatives: ['hidden', 'summary', 'detailed'],
        goals: ['metrics_viewed']
      },
      'accessibility_mode' => {
        alternatives: ['standard', 'high_contrast', 'large_text'],
        goals: ['accessibility_used']
      },
      'data_visualization' => {
        alternatives: ['charts', 'graphs', 'tables'],
        goals: ['data_explored']
      }
    }
  end

  def generate_experiment_data(experiment_name, config)
    alternatives = config[:alternatives]
    goals = config[:goals]

    # Generate participants for each alternative
    alternatives.each do |alternative|
      participants_for_alternative = (@participants / alternatives.length.to_f).round

      participants_for_alternative.times do |i|
        user_id = "user_#{experiment_name}_#{alternative}_#{i}_#{SecureRandom.hex(8)}"

        # Record participation
        record_participation(experiment_name, alternative, user_id)

        # Generate conversions based on ratio
        if rand < @conversions_ratio && goals.any?
          goal = goals.sample
          record_conversion(experiment_name, alternative, goal, user_id)
        end

        # Show progress
        if @verbose && (i + 1) % 100 == 0
          print "."
          $stdout.flush
        end
      end
    end

    puts "\n  ✓ #{experiment_name}: #{@participants} participants" if @verbose
  end

  def record_participation(experiment_name, alternative, user_id)
    # Split stores participation data in Redis
    # Key format: split:{experiment_name}:{alternative}
    key = "split:#{experiment_name}:#{alternative}"
    @redis.sadd(key, user_id)

    # Also store in the main experiment key
    @redis.hset("split:#{experiment_name}", alternative, @redis.scard(key))
  end

  def record_conversion(experiment_name, alternative, goal, user_id)
    # Store conversion data
    # Key format: split:{experiment_name}:{alternative}:{goal}
    conversion_key = "split:#{experiment_name}:#{alternative}:#{goal}"
    @redis.sadd(conversion_key, user_id)

    # Update conversion counts
    conversion_count_key = "split:#{experiment_name}:#{alternative}:#{goal}:count"
    @redis.incr(conversion_count_key)
  end

  def print_summary
    puts "\n" + "=" * 50
    puts "TEST DATA SUMMARY"
    puts "=" * 50

    total_participants = 0
    total_conversions = 0

    @experiments.each do |experiment_name, config|
      experiment_participants = 0
      experiment_conversions = 0

      config[:alternatives].each do |alternative|
        # Count participants
        participant_key = "split:#{experiment_name}:#{alternative}"
        participants = @redis.scard(participant_key)
        experiment_participants += participants

        # Count conversions
        config[:goals].each do |goal|
          conversion_key = "split:#{experiment_name}:#{alternative}:#{goal}"
          conversions = @redis.scard(conversion_key)
          experiment_conversions += conversions
        end
      end

      puts "#{experiment_name}:"
      puts "  Participants: #{experiment_participants}"
      puts "  Conversions: #{experiment_conversions}"
      puts "  Conversion Rate: #{experiment_participants > 0 ? ((experiment_conversions.to_f / experiment_participants) * 100).round(2) : 0}%"
      puts ""

      total_participants += experiment_participants
      total_conversions += experiment_conversions
    end

    puts "TOTALS:"
    puts "Total Participants: #{total_participants}"
    puts "Total Conversions: #{total_conversions}"
    puts "Overall Conversion Rate: #{total_participants > 0 ? ((total_conversions.to_f / total_participants) * 100).round(2) : 0}%"
    puts ""
    puts "Redis Keys Created: #{@redis.keys('split:*').length}"
  end
end

# Command line interface
if __FILE__ == $0
  options = {}

  OptionParser.new do |opts|
    opts.banner = "Usage: #{$0} [options]"

    opts.on("-p", "--participants COUNT", Integer, "Number of participants per experiment (default: 10000)") do |participants|
      options[:participants] = participants
    end

    opts.on("-r", "--conversion-ratio RATIO", Float, "Conversion ratio 0.0-1.0 (default: 0.1)") do |ratio|
      if ratio < 0 || ratio > 1
        puts "Conversion ratio must be between 0.0 and 1.0"
        exit 1
      end
      options[:conversions_ratio] = ratio
    end

    opts.on("--redis-url URL", "Redis URL (default: redis://localhost:6379)") do |url|
      options[:redis_url] = url
    end

    opts.on("-v", "--verbose", "Verbose output") do
      options[:verbose] = true
    end

    opts.on("-c", "--clear", "Clear existing data before generating") do
      options[:clear] = true
    end

    opts.on("--clear-only", "Only clear existing data, don't generate new") do
      options[:clear_only] = true
    end

    opts.on("--help", "Show this help") do
      puts opts
      exit
    end
  end.parse!

  begin
    generator = SplitTestDataGenerator.new(options)

    if options[:clear] || options[:clear_only]
      generator.clear_data
    end

    unless options[:clear_only]
      generator.generate
    end

  rescue Redis::CannotConnectError
    puts "Error: Cannot connect to Redis. Make sure Redis is running."
    puts "Try: redis-server"
    exit 1
  rescue => e
    puts "Error: #{e.message}"
    exit 1
  end
end