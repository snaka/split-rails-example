#!/usr/bin/env ruby
# frozen_string_literal: true

# Script to clear all Split test results
# Usage: rails runner scripts/clear_split_test_results.rb [options]
#
# Options:
#   --dry-run: Show what would be deleted without actually deleting
#   --experiment=NAME: Clear only specific experiment
#   --preserve-config: Keep experiment configurations, clear only result data

require 'optparse'

class SplitTestResultsCleaner
  def initialize(options = {})
    @dry_run = options[:dry_run]
    @specific_experiment = options[:experiment]
    @preserve_config = options[:preserve_config]
    @redis = Split.redis
    @deleted_keys = []
    @modified_keys = []
  end

  def run
    puts "Split Test Results Cleaner Script"
    puts "=================================="
    puts "Mode: #{@dry_run ? 'DRY RUN (no actual deletion)' : 'ACTUAL DELETION'}"
    puts "Target: #{@specific_experiment || 'All experiments'}"
    puts "Preserve Config: #{@preserve_config ? 'YES' : 'NO'}"
    puts

    clear_split_cache

    if @specific_experiment
      clear_specific_experiment(@specific_experiment)
    else
      clear_all_experiments
    end

    clear_global_data unless @preserve_config

    print_summary
  end

  private

  def clear_split_cache
    puts "1. Clear Split internal cache"
    unless @dry_run
      Split::Cache.clear
      puts "   ✓ Internal cache cleared"
    else
      puts "   → Will clear internal cache"
    end
    puts
  end

  def clear_specific_experiment(experiment_name)
    puts "2. Clear results for experiment '#{experiment_name}'"

    experiment = Split::Experiment.find(experiment_name)
    unless experiment
      puts "   ✗ Experiment '#{experiment_name}' not found"
      return
    end

    clear_experiment_data(experiment)
  end

  def clear_all_experiments
    puts "2. Clear results for all experiments"

    experiment_names = @redis.smembers(:experiments)
    puts "   Target experiments: #{experiment_names.size}"

    experiment_names.each do |experiment_name|
      experiment = Split::Experiment.find(experiment_name)
      next unless experiment

      puts "   Processing: #{experiment_name}"
      clear_experiment_data(experiment)
    end
  end

  def clear_experiment_data(experiment)
    # Clear result data for each alternative
    experiment.alternatives.each do |alternative|
      clear_alternative_results(alternative, experiment)
    end

    # Clear goal data
    clear_experiment_goals(experiment)

    # Clear experiment configuration (if preserve_config is false)
    clear_experiment_config(experiment) unless @preserve_config
  end

  def clear_alternative_results(alternative, experiment)
    # Build key manually since key method is private
    key = "#{alternative.experiment_name}:#{alternative.name}"

    # Fields to clear for result data
    result_fields = %w[participant_count completed_count]

    # Goal-specific completed_count fields
    experiment.goals.each do |goal|
      result_fields << "completed_count:#{goal}"
    end

    # p_winner fields (default and goal-specific)
    result_fields << "p_winner"
    experiment.goals.each do |goal|
      result_fields << "p_winner:#{goal}"
    end

    existing_fields = @redis.hkeys(key)
    fields_to_delete = result_fields & existing_fields

    if fields_to_delete.any?
      puts "     #{alternative.name}: #{fields_to_delete.join(', ')}"

      unless @dry_run
        fields_to_delete.each do |field|
          @redis.hdel(key, field)
        end
      end

      @modified_keys << key
    end
  end

  def clear_experiment_goals(experiment)
    goals_key = experiment.goals_key

    if @redis.exists?(goals_key)
      puts "     Goal data: #{goals_key}"

      unless @dry_run
        @redis.del(goals_key)
      end

      @deleted_keys << goals_key
    end
  end

  def clear_experiment_config(experiment)
    config_key = "experiment_configurations/#{experiment.name}"

    if @redis.exists?(config_key)
      puts "     Config data: #{config_key}"

      unless @dry_run
        @redis.del(config_key)
      end

      @deleted_keys << config_key
    end
  end

  def clear_global_data
    puts "3. Clear global data"

    global_keys = [
      :experiments,
      :experiment_start_times,
      :experiment_winner
    ]

    global_keys.each do |key|
      if @redis.exists?(key)
        puts "   #{key}"

        unless @dry_run
          @redis.del(key)
        end

        @deleted_keys << key.to_s
      end
    end
    puts
  end

  def print_summary
    puts "Clear Complete Summary"
    puts "======================"
    puts "Deleted keys: #{@deleted_keys.size}"
    puts "Modified keys: #{@modified_keys.size}"

    if @dry_run
      puts
      puts "※ This was a DRY RUN. No actual deletion was performed."
      puts "To actually clear data, run without the --dry-run option."
    else
      puts
      puts "✓ All test results have been cleared."
    end
  end
end

# Parse command line options
options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: rails runner scripts/clear_split_test_results.rb [options]"

  opts.on("--dry-run", "Show what would be deleted without actually deleting") do
    options[:dry_run] = true
  end

  opts.on("--experiment=NAME", "Clear only specific experiment") do |name|
    options[:experiment] = name
  end

  opts.on("--preserve-config", "Keep experiment configurations, clear only result data") do
    options[:preserve_config] = true
  end

  opts.on("-h", "--help", "Show this help message") do
    puts opts
    exit
  end
end.parse!

# Execute script
cleaner = SplitTestResultsCleaner.new(options)
cleaner.run