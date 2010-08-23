require "rubygems"
require "fileutils"
require "haml"
require "yaml"

base = File.dirname(__FILE__)

config = YAML.load(open(File.join(base, "config.yml")))

config.keys.each do |key|
  receiver = config[key]["receiver"]
  embed    = config[key]["embed"]
  channel  = config[key]["channel"]

  directory = File.join(base, key)
  FileUtils.mkdir directory unless File.exist? directory

  open(File.join(directory, "index.html"), "w") { |html|
    html.puts Haml::Engine.new(File.read(base + "/video.haml")).render(Object.new,
                                                                       { :receiver => receiver,
                                                                         :channel  => channel,
                                                                         :embed    => embed })
  }
  open(File.join(directory, receiver), "w") { |js|
    js.puts File.read(File.join(base, "receiver.js")).gsub("irc-rubykaigi2010", "irc-#{channel}")
  }
end
