class TimeUtil
  def self.time_human(time)
    minutes = time / 60
    seconds = time - minutes*60
    "#{minutes}m #{seconds}s"
  end
end
