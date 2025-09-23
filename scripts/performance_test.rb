#!/usr/bin/env ruby

require 'net/http'
require 'uri'
require 'json'
require 'optparse'
require 'benchmark'
require 'thread'
require 'securerandom'

class SplitPerformanceTest
  DEFAULT_HOST = 'localhost'
  DEFAULT_PORT = 3000
  DEFAULT_REQUESTS = 1000
  DEFAULT_CONCURRENCY = 10

  def initialize(options = {})
    @host = options[:host] || DEFAULT_HOST
    @port = options[:port] || DEFAULT_PORT
    @total_requests = options[:requests] || DEFAULT_REQUESTS
    @concurrency = options[:concurrency] || DEFAULT_CONCURRENCY
    @base_url = "http://#{@host}:#{@port}"
    @experiments = load_experiments
    @results = {
      requests_sent: 0,
      successful_requests: 0,
      failed_requests: 0,
      response_times: [],
      errors: []
    }
    @mutex = Mutex.new
  end

  def run
    puts "Starting Split Performance Test"
    puts "Target: #{@base_url}"
    puts "Total requests: #{@total_requests}"
    puts "Concurrency: #{@concurrency}"
    puts "Experiments: #{@experiments.length}"
    puts "-" * 50

    # Warm up
    puts "Warming up..."
    warmup

    # Main test
    puts "Running performance test..."

    total_time = Benchmark.realtime do
      run_concurrent_requests
    end

    # Generate test data after traffic
    puts "Generating additional test data..."
    generate_test_data

    print_results(total_time)
  end

  private

  def load_experiments
    [
      'todo_list_layout',
      'button_color',
      'priority_labels',
      'header_style',
      'sidebar_layout',
      'notification_timing',
      'search_placeholder',
      'loading_animation',
      'error_message_style',
      'pagination_size',
      'theme_switcher',
      'footer_content',
      'sort_default',
      'bulk_actions',
      'todo_preview',
      'keyboard_shortcuts',
      'auto_save',
      'attachment_display',
      'reminder_frequency',
      'export_format',
      'collaboration_ui',
      'mobile_navigation',
      'onboarding_flow',
      'performance_metrics',
      'accessibility_mode',
      'data_visualization'
    ]
  end

  def warmup
    5.times { make_request('/') }
    3.times { make_request('/split') }
  end

  def run_concurrent_requests
    requests_per_thread = @total_requests / @concurrency
    threads = []

    @concurrency.times do |i|
      threads << Thread.new do
        requests_per_thread.times do
          # Mix of different request types to simulate real usage
          case rand(10)
          when 0..2  # 30% - Dashboard access
            make_split_dashboard_request
          when 3..5  # 30% - Todo pages (triggers A/B tests)
            make_app_request
          when 6..7  # 20% - Public pages (also triggers A/B tests)
            make_public_request
          else       # 20% - Root page
            make_request('/')
          end

          # Random delay between requests (10-100ms)
          sleep(rand(0.01..0.1))
        end
      end
    end

    threads.each(&:join)
  end

  def make_split_dashboard_request
    # Split dashboard requires basic auth
    username = 'admin'
    password = 'secret'

    uri = URI("#{@base_url}/split")

    start_time = Time.now
    begin
      Net::HTTP.start(uri.host, uri.port) do |http|
        request = Net::HTTP::Get.new(uri)
        request.basic_auth(username, password)
        response = http.request(request)

        response_time = Time.now - start_time
        record_result(response.code.to_i, response_time)
      end
    rescue => e
      record_error(e, Time.now - start_time)
    end
  end

  def make_app_request
    # Simulate user session with different cookies to trigger A/B tests
    paths = ['/todos', '/todos/new', '/login', '/signup']
    path = paths.sample

    # Generate unique user session
    session_cookie = "split_session_#{SecureRandom.hex(16)}"

    start_time = Time.now
    begin
      uri = URI("#{@base_url}#{path}")
      Net::HTTP.start(uri.host, uri.port) do |http|
        request = Net::HTTP::Get.new(uri)
        request['Cookie'] = "split=#{session_cookie}"
        response = http.request(request)

        response_time = Time.now - start_time
        record_result(response.code.to_i, response_time)
      end
    rescue => e
      record_error(e, Time.now - start_time)
    end
  end

  def make_public_request
    paths = ['/about', '/features', '/pricing', '/contact', '/help', '/demo']
    path = paths.sample

    # Generate unique visitor session for A/B testing
    session_cookie = "split_visitor_#{SecureRandom.hex(16)}"

    start_time = Time.now
    begin
      uri = URI("#{@base_url}#{path}")
      Net::HTTP.start(uri.host, uri.port) do |http|
        request = Net::HTTP::Get.new(uri)
        request['Cookie'] = "split=#{session_cookie}"
        response = http.request(request)

        response_time = Time.now - start_time
        record_result(response.code.to_i, response_time)
      end
    rescue => e
      record_error(e, Time.now - start_time)
    end
  end

  def make_request(path)
    start_time = Time.now
    begin
      uri = URI("#{@base_url}#{path}")
      response = Net::HTTP.get_response(uri)

      response_time = Time.now - start_time
      record_result(response.code.to_i, response_time)
    rescue => e
      record_error(e, Time.now - start_time)
    end
  end

  def record_result(status_code, response_time)
    @mutex.synchronize do
      @results[:requests_sent] += 1
      @results[:response_times] << response_time

      if status_code >= 200 && status_code < 400
        @results[:successful_requests] += 1
      else
        @results[:failed_requests] += 1
      end

      # Progress indicator
      if @results[:requests_sent] % 100 == 0
        print "."
        $stdout.flush
      end
    end
  end

  def record_error(error, response_time)
    @mutex.synchronize do
      @results[:requests_sent] += 1
      @results[:failed_requests] += 1
      @results[:response_times] << response_time
      @results[:errors] << error.message
    end
  end

  def generate_test_data
    # Generate additional conversion data to simulate heavy usage
    conversion_goals = [
      'todo_completed', 'todo_created', 'user_engagement',
      'navigation_usage', 'notification_clicked', 'search_used',
      'user_retention', 'error_recovery', 'page_views',
      'theme_changed', 'footer_clicks', 'sort_changed',
      'bulk_operation', 'preview_used', 'shortcut_used',
      'data_saved', 'attachment_viewed', 'reminder_acted',
      'export_completed', 'collaboration_started', 'mobile_navigation',
      'onboarding_completed', 'metrics_viewed', 'accessibility_used',
      'data_explored'
    ]

    # Make requests that would trigger conversions
    (rand(50..200)).times do
      # Simulate POST requests for conversions
      path = '/todos'
      goal = conversion_goals.sample
      session_cookie = "split_conversion_#{SecureRandom.hex(16)}"

      begin
        uri = URI("#{@base_url}#{path}")
        Net::HTTP.start(uri.host, uri.port) do |http|
          request = Net::HTTP::Get.new(uri)
          request['Cookie'] = "split=#{session_cookie}; split_goal=#{goal}"
          http.request(request)
        end
      rescue => e
        # Ignore errors in test data generation
      end

      sleep(0.01) # Small delay
    end
  end

  def print_results(total_time)
    puts "\n"
    puts "=" * 50
    puts "PERFORMANCE TEST RESULTS"
    puts "=" * 50

    response_times = @results[:response_times]

    puts "Total Time: #{total_time.round(2)}s"
    puts "Total Requests: #{@results[:requests_sent]}"
    puts "Successful Requests: #{@results[:successful_requests]}"
    puts "Failed Requests: #{@results[:failed_requests]}"
    puts "Success Rate: #{((@results[:successful_requests].to_f / @results[:requests_sent]) * 100).round(2)}%"
    puts "Requests/Second: #{(@results[:requests_sent] / total_time).round(2)}"
    puts ""

    if response_times.any?
      sorted_times = response_times.sort
      puts "Response Time Statistics:"
      puts "  Average: #{(response_times.sum / response_times.length * 1000).round(2)}ms"
      puts "  Median: #{(sorted_times[sorted_times.length / 2] * 1000).round(2)}ms"
      puts "  95th Percentile: #{(sorted_times[(sorted_times.length * 0.95).to_i] * 1000).round(2)}ms"
      puts "  99th Percentile: #{(sorted_times[(sorted_times.length * 0.99).to_i] * 1000).round(2)}ms"
      puts "  Min: #{(sorted_times.first * 1000).round(2)}ms"
      puts "  Max: #{(sorted_times.last * 1000).round(2)}ms"
    end

    if @results[:errors].any?
      puts ""
      puts "Errors (first 10):"
      @results[:errors].first(10).each_with_index do |error, i|
        puts "  #{i+1}. #{error}"
      end
    end

    puts ""
    puts "You can now access the Split dashboard at: #{@base_url}/split"
    puts "Username: admin"
    puts "Password: secret"
  end
end

# Command line interface
if __FILE__ == $0
  options = {}

  OptionParser.new do |opts|
    opts.banner = "Usage: #{$0} [options]"

    opts.on("-h", "--host HOST", "Target host (default: localhost)") do |host|
      options[:host] = host
    end

    opts.on("-p", "--port PORT", Integer, "Target port (default: 3000)") do |port|
      options[:port] = port
    end

    opts.on("-r", "--requests COUNT", Integer, "Total requests (default: 1000)") do |requests|
      options[:requests] = requests
    end

    opts.on("-c", "--concurrency THREADS", Integer, "Concurrent threads (default: 10)") do |concurrency|
      options[:concurrency] = concurrency
    end

    opts.on("--help", "Show this help") do
      puts opts
      exit
    end
  end.parse!

  test = SplitPerformanceTest.new(options)
  test.run
end