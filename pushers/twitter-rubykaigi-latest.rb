require "rubygems"
require "pit"
require "json"
require "open-uri"

require "pusher"

account = Pit.get("rk2010stream", :require => {
                    "pusher-app-id"    => "Pusher app id",
                    "pusher-key"       => "Pusher key",
                    "pusher-secret"    => "Pusher secret"
                  })

Pusher.app_id = account["pusher-app-id"]
Pusher.key    = account["pusher-key"]
Pusher.secret = account["pusher-secret"]

url   = "http://api.twitter.com/1/statuses/user_timeline.json?screen_name=rubykaigi&count=1"
json  = JSON.parse(open(url).read)
tweet = json.first

puts "[@%s] %s" % [tweet["user"]["screen_name"], tweet["text"]]

Pusher["stream"].trigger("twitter", :data => tweet)
