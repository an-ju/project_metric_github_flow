require "project_metric_github_flow/version"
require 'octokit'
require 'json'
require 'date'

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
    @raw_data = commits
    @score = @image = nil
  end

  def raw_data=(new)
    @raw_data = new
    @score = nil
    @image = nil
  end

  def score
    @raw_data ||= commits
    synthesize
    @score ||= @named_nums.each_pair.inject(0) { |sum, (_, v)| sum + v}
  end

  def image
    @raw_data ||= commits
    synthesize
    @image ||= { chartType: 'github_flow',
                 titleText: 'GitHub commit frequency',
                 data: { data: @named_nums.values,
                         series: @named_nums.keys } }.to_json
  end

  def self.credentials
    %I[github_project github_access_token]
  end

  private

  def commits
    @client.commits_since @identifier, Date.today - 7
  end

  def synthesize
    @raw_data ||= commits
    @named_commits = @raw_data.group_by { |cmit| cmit[:commit][:committer][:email] }
    @named_nums = {}
    @named_commits.each_pair { |key, val| @named_nums[key] = val.length }
  end

end
