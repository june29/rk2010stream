$(document).ready(function() {
  WebSocket.__swfLocation = "WebSocketMain.swf";

  var capacity  = 20;
  var icon_size = 36;

  function format(text) {
    return text.replace(/(http:\/\/[\x21-\x7e]+)/gi,'<a href="$1" target="_blank">$1</a>')
               .replace(/@([a-zA-Z0-9_]+)/gi,'<a href="http://twitter.com/$1" target="_blank">@$1</a>')
               .replace(/#([a-zA-Z0-9_]+)/gi,'<a href="http://search.twitter.com/search?q=%23$1" target="_blank">#$1</a>');
  }

  function cutoff() {
    if ($("#stream div").size() >= capacity) {
      $("#stream div:last").slideDown(100, function() {
        $(this).remove();
      });
    }
  }

  function prepend(element) {
    element.hide().prependTo($("#stream")).slideDown("fast");
    cutoff();
  }

  var stream = new Pusher("103f2d7ba59163142c42", "stream");
  var notice = new Pusher("103f2d7ba59163142c42", "notice");

  stream.bind("twitter", function(message) {
    var data = message.data;
    var user = data.user;

    if (user) {
      var id                = data.id;
      var text              = data.text;
      var screen_name       = user.screen_name;
      var profile_image_url = user.profile_image_url;
      var d                 = new Date(data.created_at);
      var created_at_text   = d.getFullYear() + "/" + d.getMonth() + "/" + d.getDate()
                            + " " + d.getHours() + ":" + d.getMinutes() + ":" + d.getSeconds();

      var div = $("<div/>")
                .addClass("tweet")
                .append($("<p/>")
                        .append($("<img/>")
                                .addClass("icon")
                                .attr({ src: profile_image_url, alt: screen_name, width: icon_size, height: icon_size }))
                        .append($("<span/>")
                                .addClass("screen_name")
                                .append($("<a/>")
                                        .attr({ href: "http://twitter.com/" + screen_name + "/status/" + id, target: "_blank" })
                                        .text(screen_name))
                                .append(":"))
                        .append(format(text)));

      prepend(div);
    }
  });

  stream.bind("irc-%s", function(message) {
    var data       = message.body;
    var nick       = data.nick;
    var text       = data.text;
    var created_at = data.created_at;

    var div = $("<div/>")
      .addClass("irc")
      .append($("<p/>")
              .append($("<img/>")
                      .addClass("icon")
                      .attr({ src: "irc.png", alt: "irc", width: icon_size, height: icon_size }))
              .append($("<span/>")
                      .addClass("screen_name")
                      .text(nick + ":"))
              .append(format(text)));

    prepend(div);
  });

  notice.bind("text", function(message) {
    var data       = message.data;
    var body       = data.body;
    var updated_at = data.updated_at;

    var div = $("#notice");

    div.contents().remove();

    div.append($("<span/>").hide()
               .addClass("message")
               .text(body + " (updated: " + updated_at + ")").fadeIn(2000));
  });
});
