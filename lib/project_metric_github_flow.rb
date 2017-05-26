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
    @score ||= @dated_nums.each_value.inject { |sum, elem| sum + elem }.to_f / @dated_nums.size
  end

  def image
    @raw_data ||= commits
    synthesize
    image_data = (Date.today - 7..Date.today).map do |date|
      @dated_nums.has_key?(date.to_s) ? @dated_nums[date.to_s] : 0
    end
    @image ||= { chartType: 'github_flow',
                 titleText: 'GitHub commit frequency',
                 data: { data: image_data,
                         series: (Date.today - 7..Date.today) } }.to_json
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
    @dated_commits = @raw_data.group_by { |cmit| cmit[:commit][:committer][:date].to_date.to_s }
    @dated_nums = {}
    @dated_commits.each_pair do |key, val|
      @dated_nums[key] = val.length
    end
  end

end
