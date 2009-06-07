class TweetTail::HtmlTweetFormatter
  def self.format(tweet)
    screen_name = tweet['from_user']
    created_at = tweet['created_at']
    link = tweet['source']
    message = tweet['text']
    "<div class='tweet'>\n#{screen_name}: #{message}<br />\n<a href='#{link}'>#{created_at}</a>\n</div>\n"
  end
end