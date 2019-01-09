class ProjectMetricGithubFlow
  def self.fake_data
    [fake_metric(10, 2), fake_metric(20, 1), fake_metric(0, 0)]
  end

  def self.fake_metric(pushes, branches)
    { score: pushes + branches + 3,
      image: fake_image(pushes, branches)
    }
  end

  def self.fake_image(pushes, branches)
    push_events = Array.new(pushes) { push_event(Time.now - 60*60*rand(24 * 3))}
    branch_events = Array.new(branches) { branch_event(Time.now - 60*60*rand(24*3))}
    { chatType: 'github_flow',
      data: { pushes: push_events,
              branches: branch_events,
              network_link: 'https://github.com/an-ju/projectscope/network' } }
  end

  def self.push_event(create_time)
    { :id=>"8577866086",
      :type=>"PushEvent",
      :actor=>{ :id=>5564756,
                :login=>"an-ju",
                :display_login=>"an-ju",
                :gravatar_id=>"",
                :url=>"https://api.github.com/users/an-ju",
                :avatar_url=>"https://avatars.githubusercontent.com/u/5564756?"},
      :repo=>{ :id=>72873514,
               :name=>"an-ju/projectscope",
               :url=>"https://api.github.com/repos/an-ju/projectscope"},
      :payload=>{ :push_id=>3043072222,
                  :size=>1,
                  :distinct_size=>1,
                  :ref=>"refs/heads/160837077-demo-story-3",
                  :head=>"66ad7065ad3e33d99cdd35b01914cbbf2befa97f",
                  :before=>"08d20572854ed07a9c173f7456b62069eac2eee0",
                  :commits=>[{ :sha=>"66ad7065ad3e33d99cdd35b01914cbbf2befa97f",
                               :author=>{:email=>"an_ju@berkeley.edu", :name=>"An Ju"},
                               :message=>"[160837077] test",
                               :distinct=>true,
                               :url=>"https://api.github.com/repos/an-ju/projectscope/commits/66ad7065ad3e33d99cdd35b01914cbbf2befa97f"}]},
      :public=>true,
      :created_at=>create_time}
  end

  def self.branch_event(create_time)
    { :id=>"8577691653",
      :type=>"CreateEvent",
      :actor=>{ :id=>5564756,
                :login=>"an-ju",
                :display_login=>"an-ju",
                :gravatar_id=>"",
                :url=>"https://api.github.com/users/an-ju",
                :avatar_url=>"https://avatars.githubusercontent.com/u/5564756?" },
      :repo=>{ :id=>72873514,
               :name=>"an-ju/projectscope",
               :url=>"https://api.github.com/repos/an-ju/projectscope" },
      :payload=>{ :ref=>"branch-demo",
                  :ref_type=>"branch",
                  :master_branch=>"develop",
                  :description=>"ProjectScope developed for CS169 at UC Berkeley.",
                  :pusher_type=>"user" },
      :public=>true,
      :created_at=>create_time}
  end
end