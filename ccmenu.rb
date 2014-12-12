# circle.rb

# Shoes.show_log

require_relative 'config/env'


unless defined?(Shoes)
  # calling it from ruby  (builds are returned)
  require 'pp'
  circle = Circle.new
  builds = circle.builds
  pp builds
else
  # calling it from shoes (ui is spawn)

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
          refresh_builds!

          `aplay ding.wav` if @changes
          @changes = false
          sleep 10
        end
      end
    end

    def get_status(builds)
      builds.map{ |b| { id: b.id, status: b.status } }
    end

    def refresh_builds!
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
              button("run") do
                Circle.new.run build.id
              end
              button("cancel") do
                Circle.new.cancel build.id
                refresh_builds!
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
