require "spec_helper"

RSpec.describe ProjectMetricGithubFlow do
  context 'meta data' do
    it "has a version number" do
      expect(ProjectMetricGithubFlow::VERSION).not_to be nil
    end
  end

  context 'image and score' do
    subject(:metric) do
      described_class.new github_project: 'https://github.com/an-ju/projectscope', github_token: 'test token'
    end

    before :each do
      client = double('client')
      events_raw = double('raw events')

      allow(Octokit::Client).to receive(:new).and_return(client)
      allow(client).to receive(:auto_paginate=)
      allow(client).to receive(:repository_events).with('an-ju/projectscope').and_return(events_raw)
      allow(events_raw).to receive(:select) { JSON.parse(File.read('spec/data/events.json')) }
    end

    it 'should generate the right score' do
      expect(metric.score).to eql(30)
    end

    it 'should generate an image' do
      expect(metric.image).to be_a(Hash)
    end

    it 'should set the image values correctly' do
      image = metric.image
      expect(image[:data][:new_pushes]).not_to be_nil
      expect(image[:data][:new_branches]).not_to be_nil
      expect(image[:data][:network_link]).not_to be_nil
    end
  end

  context 'test generator' do
    it 'should generate fake data' do
      expect(described_class.fake_data.length).to eql(3)
    end

    it 'should contain the right keys' do
      metric = described_class.fake_data.first
      expect(metric).to have_key(:image)
      expect(metric).to have_key(:score)
    end

    it 'should set image data correctly' do
      image = described_class.fake_data.first[:image]
      expect(image[:data][:pushes]).not_to be_nil
      expect(image[:data][:branches]).not_to be_nil
      expect(image[:data][:network_link]).not_to be_nil
    end
  end

end
