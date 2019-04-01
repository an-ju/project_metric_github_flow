require "project_metric_github_flow/version"
require 'project_metric_github_flow/test_generator'
require 'octokit'
require 'json'
require 'date'
require 'time'
require 'project_metric_base'

class ProjectMetricGithubFlow
  include ProjectMetricBase
  add_credentials %I[github_project github_access_token]
  add_raw_data %w[github_events]

  def initialize(credentials, raw_data = nil)
    @project_url = credentials[:github_project]
    @identifier = URI.parse(@project_url).path[1..-1]
    @client = Octokit::Client.new access_token: credentials[:github_access_token]
    @client.auto_paginate = true

    complete_with raw_data
  end

  def score
    # Number of github events that happened in the past N days
    @github_events.length
  end

  def image
    refresh unless @raw_data
    @image ||= { chartType: 'github_flow',
                 data: { new_pushes: new_pushes,
                         new_branches: new_branches,
                         network_link: "https://github.com/#{@identifier}/network" } }
  end

  def obj_id
    nil
  end

  private

  def github_events
    # Events in the past two weeks
    events = @client.repository_events(@identifier)
                    .select { |event| event[:created_at] > (Time.now - 14*24*60*60) }
    @github_events = JSON.parse(events.to_json)
  end

  def new_pushes
    @github_events.select { |event| event['type'].eql? 'PushEvent' }
  end

  def new_branches
    @github_events.select { |event| event['type'].eql? 'CreateEvent' and event['payload']['ref_type'].eql? 'branch' }
  end

end
