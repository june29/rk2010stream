require "rubygems"
require "pit"
require "pusher"

message = ARGV[0]
raise "please give a message" if message.nil?

account = Pit.get("rk2010stream", :require => {
                    "pusher-app-id"    => "Pusher app id",
                    "pusher-key"       => "Pusher key",
                    "pusher-secret"    => "Pusher secret"
                  })

Pusher.app_id = account["pusher-app-id"]
Pusher.key    = account["pusher-key"]
Pusher.secret = account["pusher-secret"]

Pusher["sample"].trigger("data", :body => { :message => message })
