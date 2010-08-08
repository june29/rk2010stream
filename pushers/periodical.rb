require "rubygems"
require "pit"
require "json"

require "pusher"

account = Pit.get("rk2010stream", :require => {
                    "pusher-app-id"    => "Pusher app id",
                    "pusher-key"       => "Pusher key",
                    "pusher-secret"    => "Pusher secret"
                  })

Pusher.app_id = account["pusher-app-id"]
Pusher.key    = account["pusher-key"]
Pusher.secret = account["pusher-secret"]

loop do
  created_at = Time.now.strftime("%Y/%m/%d %H:%M:%S")
  puts created_at
  Pusher["dummy"].trigger("data", :body => { :created_at => created_at })

  sleep 10
end
