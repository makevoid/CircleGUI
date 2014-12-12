class Circle
  def self.builds
    new.builds
  end

  ACCESS_TOKEN = CIRCLE_ACCESS_TOKEN
  # URL = "https://circleci.com/api/v1/me?circle-token=#{ACCESS_TOKEN}"
  URL = "https://circleci.com/api/v1/project/quillcontent/wms?circle-token=#{ACCESS_TOKEN}&limit=10&offset=0"


  def builds
    resp = Net::HTTP.get_response URI.parse URL
    builds = JSON.parse resp.body

    builds.map do |build|
      stop_time   = build["stop_time"]
      stop_time   = Time.parse stop_time if stop_time
      build_time  = build["build_time_millis"]
      lifecycle   = build["lifecycle"]  # :queued, :scheduled, :not_run, :not_running, :running or :finished
      outcome     = build["outcome"]    # :canceled, :infrastructure_fail, :timedout, :failed, :no_tests or :success

      id          = build["build_num"].to_i
      finished_at = stop_time
      build_time  = build_time / 1000 if build_time
      failed      = build["failed"]
      lifecycle   = lifecycle.to_sym if lifecycle
      outcome     = outcome.to_sym if outcome
      author      = build["author_name"] # author_name | author_login | committer_login
      subject     = build["subject"]
      build_url   = build["build_url"]
      compare_url = build["compare_url"]

      Build.new(
                  id:           id,
                  finished_at:  finished_at,
                  build_time:   build_time,
                  failed:       failed,
                  lifecycle:    lifecycle,
                  outcome:      outcome,
                  author:       author,
                  subject:      subject,
                  build_url:    build_url,
                  compare_url:  compare_url
              )
    end.sort_by{ |b| -b.id }
  end
end