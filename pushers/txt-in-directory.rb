require "rubygems"
require "pit"
require "pusher"

directory = ARGV.shift
raise "please give a target directory" if directory.nil?

account = Pit.get("rk2010stream", :require => {
                    "pusher-app-id"    => "Pusher app id",
                    "pusher-key"       => "Pusher key",
                    "pusher-secret"    => "Pusher secret"
                  })

Pusher.app_id = account["pusher-app-id"]
Pusher.key    = account["pusher-key"]
Pusher.secret = account["pusher-secret"]

logger = Logger.new(STDOUT)
previous = nil

loop do
  begin
    picked     = Dir["#{directory}/*.txt"].reject { |name| name == previous }.choice
    body       = File.read(picked).chomp
    updated_at = File.ctime(picked).strftime("%Y/%m/%d %H:%M:%S")

    logger.info("[%s] : %s" % [updated_at, body])

    Pusher["notice"].trigger("text", :data => { :body => body, :updated_at => updated_at })
    previous = picked

    sleep 5
  rescue => e
    logger.error(e)
  end
end
