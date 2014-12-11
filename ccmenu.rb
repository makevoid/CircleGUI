# circle.rb

# Shoes.show_log

require 'net/http'
require 'json'
require 'time'

class Circle
  def self.builds
    new.builds
  end

  ACCESS_TOKEN = File.read( File.expand_path "~/.circle_ci" ).strip
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

class TimeUtil
  def self.time_human(time)
    minutes = time / 60
    seconds = time - minutes*60
    "#{minutes}m #{seconds}s"
  end
end

class Build
  attr_reader :id, :finished_at, :build_time, :failed, :lifecycle, :outcome, :author, :subject, :build_url, :compare_url

  def initialize(id:, finished_at:, build_time:, failed:, lifecycle:, outcome:, author:, subject:, build_url:, compare_url:)
    @id           = id
    @finished_at  = finished_at
    @build_time   = build_time
    @failed       = failed
    @lifecycle    = lifecycle
    @outcome      = outcome
    @author       = author
    @subject      = subject
    @build_url    = build_url
    @compare_url  = compare_url
  end

  def status
    return outcome if [:canceled, :failed, :success].include? outcome
    lifecycle # :queued, :scheduled, :not_run, :running, :finished
  end

  def build_time_human
    TimeUtil.time_human build_time if build_time
  end

  def color
    return :blue   if [:running].include? status
    return :green  if status == :success
    return :orange if status == :not_run
    return :red    if status == :failed
    :gray
  end
end

###

unless defined?(Shoes)
  require 'pp'
  circle = Circle.new
  builds = circle.builds
  pp builds
else
  BROWSER = "google-chrome"
  # BROWSER = "firefox"

  Shoes.app title: "CCMenu" do

    puts "starting"
    fill "#FFF"
    strokewidth 0
    cap :curve

    stack margin: 10 do
      @last_build = stack { }
      @slot = stack { }
      @changes = false
      @build_status = nil

      Thread.new do
        while true
          repaint_slot

          `aplay ding.wav` if @changes
          @changes = false
          sleep 10
        end
      end
    end

    def get_status(builds)
      builds.map{ |b| { id: b.id, status: b.status } }
    end

    def repaint_slot
      # puts "repainting"

      circle = Circle.new
      builds = circle.builds
      builds_status = get_status builds

      if @build_status && builds_status != @build_status
        @changes = true
      end

      @slot.clear
      builds.each do |build|
        @slot.append do
          stack margin: 8 do
            background white
            flow margin: 4 do
              fill send(build.color)
              oval(left: 10, top: 4, radius: 12)
              para "         "
              id = para "##{build.id}"
              para "   "
              author = para build.author
              para "   "
              para build.build_time_human
              para "   "
              if build.finished_at
                time = Time.now - build.finished_at
                para "ended #{TimeUtil.time_human(time.to_i)} ago"
                para "   "
              end
              status = para build.status
              para "   "
              button("open") do
                puts `#{BROWSER} #{build.build_url}`
              end
              stack do
                para build.subject
              end
            end
          end
        end
      end

      @build_status = builds_status
    end
  end # Shoes

end
