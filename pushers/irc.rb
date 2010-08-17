require "rubygems"
require "net/irc"
require "pit"
require "json"
require "pusher"

class IRCPusher < Net::IRC::Client
  def initialize(*arguments)
    super
    @channels = opts.channels

    account = Pit.get("rk2010stream", :require => {
                        "pusher-app-id"    => "Pusher app id",
                        "pusher-key"       => "Pusher key",
                        "pusher-secret"    => "Pusher secret"
                      })

    Pusher.app_id = account["pusher-app-id"]
    Pusher.key    = account["pusher-key"]
    Pusher.secret = account["pusher-secret"]
  end

  def on_rpl_welcome(m)
    @channels.each do |channel|
      post JOIN, channel
    end
  end

  def on_privmsg(m)
    channel, message = *m
    nick = m.prefix.nick.to_s
    created_at = Time.now.strftime("%Y/%m/%d %H:%M:%S")

    Pusher["stream"].trigger("irc-%s" % channel.sub(/^#/, "").downcase,
                             :body => { :nick => nick, :text => message, :created_at => created_at })
  end
end

account = Pit.get("rk2010stream", :require => {
                    "freenode-nick"     => "freenode nick",
                    "freenode-user"     => "freenode user",
                    "freenode-real"     => "freenode real",
                    "freenode-password" => "freenode password"
                  })

channels = ARGV.map { |channel| "#" + channel }

client = IRCPusher.new("irc.freenode.net", 6667,
                       { :nick => account["freenode-nick"],
                         :user => account["freenode-user"],
                         :real => account["freenode-real"],
                         :pass => account["freenode-password"],
                         :channels => channels })
client.start
