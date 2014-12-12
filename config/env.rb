path = File.expand_path "../", __FILE__

CIRCLE_ACCESS_TOKEN = File.read( File.expand_path "~/.circle_ci" ).strip

require "#{path}/lib/circle"
require "#{path}/lib/timeutil"
require "#{path}/lib/build"
