require "rubygems"
require "pit"
require "json"
require "open-uri"

require "pusher"

target   =  ARGV[0]
interval = (ARGV[1] || "60").to_i
raise "please set a target" if target.nil?

account = Pit.get("rk2010stream", :require => {
                    "pusher-app-id"    => "Pusher app id",
                    "pusher-key"       => "Pusher key",
                    "pusher-secret"    => "Pusher secret"
                  })

Pusher.app_id = account["pusher-app-id"]
Pusher.key    = account["pusher-key"]
Pusher.secret = account["pusher-secret"]

logger = Logger.new(STDOUT)

logger.info "[target  : @#{target}]"
logger.info "[interval: #{interval} sec]"

url   = "http://api.twitter.com/1/statuses/user_timeline.json?screen_name=#{target}"
json  = JSON.parse(open(url).read)
latest = json.first["id"]

loop do
  begin
    tweets = JSON.parse(open(url).read).reverse

    tweets.each do |tweet|
      next if tweet["id"] <= latest

      logger.info tweet["text"]
      Pusher["stream"].trigger("twitter", :data => tweet)

      latest = tweet["id"]
    end
  rescue => e
    logger.error e
  end

  sleep interval
end
