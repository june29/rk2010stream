require "rubygems"
require "twitter/json_stream"
require "eventmachine"
require "yajl"
require "pit"
require "pusher"

query = ARGV.shift
raise "please give some query" if query.nil?

account = Pit.get("rk2010stream", :require => {
                    "twitter-username" => "Twitter username",
                    "twitter-password" => "Twitter password",
                    "pusher-app-id"    => "Pusher app id",
                    "pusher-key"       => "Pusher key",
                    "pusher-secret"    => "Pusher secret"
                  })

Pusher.app_id = account["pusher-app-id"]
Pusher.key    = account["pusher-key"]
Pusher.secret = account["pusher-secret"]

logger = Logger.new(STDOUT)

EventMachine::run {
  EventMachine::defer {
    stream = Twitter::JSONStream.connect(
               :path => "/1/statuses/filter.json?track=#{query}",
               :auth => "#{account['twitter-username']}:#{account['twitter-password']}"
             )

    stream.each_item do |status|
      json = Yajl.load(status)
      logger.info("[@%s] %s" % [json["user"]["screen_name"], json["text"]])

      Pusher["stream"].trigger("twitter", :data => json)
    end
  }
}
