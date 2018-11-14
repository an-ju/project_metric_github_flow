require "project_metric_github_flow/version"
require 'project_metric_github_flow/test_generator'
require 'octokit'
require 'json'
require 'date'
require 'time'

class ProjectMetricGithubFlow
  attr_reader :raw_data

  def initialize(credentials, raw_data = nil)
    @project_url = credentials[:github_project]
    @identifier = URI.parse(@project_url).path[1..-1]
    @client = Octokit::Client.new access_token: credentials[:github_access_token]
    @client.auto_paginate = true

    @raw_data = raw_data
  end

  def refresh
    set_events
    @raw_data = { events: @events.map(&:to_h) }.to_json
  end

  def raw_data=(new)
    @raw_data = new
    @events = JSON.parse(@raw_data)['events']
  end

  def score
    refresh unless @raw_data
    # Number of github events that happened in the past N days
    @events.length
  end

  def image
    refresh unless @raw_data
    @image ||= { chartType: 'github_flow',
                 data: { new_pushes: new_pushes,
                         new_branches: new_branches,
                         network_link: "https://github.com/#{@identifier}/network" } }.to_json
  end

  def self.credentials
    %I[github_project github_access_token]
  end

  private

  def set_events
    # Events in the past three days
    @events = @client.repository_events(@identifier)
                     .select { |event| event[:created_at] > (Time.now - 3*24*60*60) }
  end

  def new_pushes
    @events.select { |event| event[:type].eql? 'PushEvent' }
  end

  def new_branches
    @events.select { |event| event[:type].eql? 'CreateEvent' and event[:payload][:ref_type].eql? 'branch' }
  end

end
