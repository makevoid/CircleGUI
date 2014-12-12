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
