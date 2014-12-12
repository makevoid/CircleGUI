path = File.expand_path "../../", __FILE__

require 'net/http'
require 'json'
require 'time'

CIRCLE_ACCESS_TOKEN = File.read( File.expand_path "~/.circle_ci" ).strip
CIRCLE_CURRENT_PROJECT = "quillcontent/wms"

require "#{path}/lib/circle"
require "#{path}/lib/timeutil"
require "#{path}/lib/build"
