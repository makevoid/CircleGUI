class Circle
  def self.builds
    new.builds
  end

  ENDPOINT = "https://circleci.com/api/v1/project"

  ACCESS_TOKEN  = CIRCLE_ACCESS_TOKEN
  PROJECT       = CIRCLE_CURRENT_PROJECT

  # URL_ME = "https://circleci.com/api/v1/me?circle-token=#{ACCESS_TOKEN}"
  URL_BUILDS = "#{ENDPOINT}/#{PROJECT}?circle-token=#{ACCESS_TOKEN}&limit=10&offset=0"
  URL_RUN    = "#{ENDPOINT}/#{PROJECT}/%s/retry?circle-token=#{ACCESS_TOKEN}"
  URL_CANCEL = "#{ENDPOINT}/#{PROJECT}/%s/cancel?circle-token=#{ACCESS_TOKEN}"

  def run(build_num)
    url_run = URL_RUN % build_num.to_s
    post_json url_run
  end

  def cancel(build_num)
    url_run = URL_CANCEL % build_num.to_s
    post_json url_run
  end

  def builds
    builds = get_json URL_BUILDS

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


  private

  def get_json(url)
    # puts "GET #{url}"
    resp = Net::HTTP.get_response URI.parse url
    JSON.parse resp.body
  end

  def post_json(url)
    puts "POST #{url}"
    uri  = URI.parse url
    resp = Net::HTTP.post_form uri, { "circle-token" => ACCESS_TOKEN }
    JSON.parse resp.body
  end

end

# Example using run
#
#
# puts Circle.new.run 1270
#
