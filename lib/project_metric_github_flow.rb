require "project_metric_github_flow/version"
require 'octokit'
require 'json'

class ProjectMetricGithubFlow
  attr_reader :raw_data

  def initialize(credentials, raw_data = nil)
    @project_url = credentials[:project]
    @identifier = URI.parse(@project_url).path[1..-1]
    @client = Octokit::Client.new access_token: credentials[:token]
    @client.auto_paginate = true

    @raw_data = raw_data
  end

  def image
    refresh unless @raw_data
    { chartType: 'commit_flow',
      titleText: 'Commit Flow',
      data: @raw_data }.to_json
  end

  def refresh
    @raw_data = {commits: commits.map(&:to_h) }
  end

  def raw_data=(new)
    @raw_data = new
    @score = nil
    @image = nil
  end

  def score
    refresh unless @raw_data
    @score = @raw_data[:data].length
  end

  private

  def commits
    @client.commits @identifier
  end

end
