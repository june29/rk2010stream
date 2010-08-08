require "uri"
require "logger"

require "rubygems"
require "eventmachine"
require "pit"
require "json"

require "pusher"

class TwitterUserStreamClient < EM::Protocols::LineAndTextProtocol
  attr_reader :logger

  def initialize(path, login, password, logger, block)
    super()
    @path = path
    @login, @password = login, password
    @logger = logger
    @block = block
  end

  def connection_completed
    logger.info "[%s] connection completed" % @login
    @state = :header
    @headers = []
    auth = [[@login, @password].join(':')].pack("m").chomp
    send_data(
              ["GET #{@path} HTTP/1.0", "Authorization: Basic %s" % auth].join("\r\n") +
      "\r\n\r\n"
    )
  end

  def receive_line line
    case @state
    when :header
      if line == ""
        logger.info "[%s] %s" % [@login, @headers.first]
        http_version, code, message = @headers.first.split(/\s+/, 3)
        if code != "200"
          logger.error "server returns #{@headers.first}"
          raise "server returns #{@headers.first}"
        end
        @state = :body
      else
        @headers << line.chomp
      end
    when :body
      @block.call(line) unless line.empty?
    end
  end

  def unbind
    super
    logger.info "[%s] disconnected" % @login
    exit
  end
end

def connect_user_stream(login, password, logger, uri=nil, &block)
  uri ||= URI("http://chirpstream.twitter.com/2b/user.json")

  EventMachine::run {
    EventMachine::connect(uri.host, uri.port, TwitterUserStreamClient, uri.path, login, password, logger, block)
  }
end

logger = Logger.new(STDOUT)

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

connect_user_stream(account["twitter-username"], account["twitter-password"], logger) do |data|
  json = JSON.parse(data)

  if json["user"]
    logger.info("[%s][@%s] %s" % [json["user"]["protected"] ? "P" : " ",
                                  json["user"]["screen_name"],
                                  json["text"]])
    Pusher["stream"].trigger("twitter", :data => json) unless json["user"]["protected"]
  end
end
