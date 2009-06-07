require File.dirname(__FILE__) + '/test_helper.rb'

class TestTweetPoller < Test::Unit::TestCase

  def setup
    @app = TweetTail::TweetPoller.new('jaoo')
    @app.expects(:initial_json_data).returns(<<-JSON)
    {
        "results": [{
            "text": "reading my own abstract for JAOO presentation",
            "from_user": "drnic",
            "id": 1666627310,
            "created_at": "10:45 PM Apr 30th",
            "source" : "https://twitter.com/drnic/status/1666627310"
        },{
            "text": "Come speak with Matt at JAOO next week",
            "from_user": "theRMK",
            "id": 1666334207,
            "created_at": "10:01 PM Apr 30th",
            "source": "http://twitter.com/theRMK/statuses/1666334207"
        },{
            "text": "@VenessaP I think they went out for noodles. #jaoo",
            "from_user": "Steve_Hayes",
            "id": 1666166639,
            "created_at": "10:01 PM Apr 30th",
            "source": "http://not.in.google/"
        },{
            "text": "Come speak with me at JAOO next week - http:\/\/jaoo.dk\/",
            "from_user": "mattnhodges",
            "id": 1664823944,
            "created_at": "10:01 PM Apr 30th",
            "source": "http://not.in.google/"
        }],
        "refresh_url": "?since_id=1682666650&q=jaoo"
    }
    JSON
    @app.refresh
  end
  
  def test_found_results
    assert_equal(4, @app.latest_results.length)
  end
  
  def test_message_render
    expected = <<-RESULTS.gsub(/^    /, '')
    mattnhodges: Come speak with me at JAOO next week - http://jaoo.dk/
    Steve_Hayes: @VenessaP I think they went out for noodles. #jaoo
    theRMK: Come speak with Matt at JAOO next week
    drnic: reading my own abstract for JAOO presentation
    RESULTS
    assert_equal(expected, @app.render_latest_results(nil))
  end
  
  def test_message_render_html_block
    expected = <<-RESULTS.gsub(/^    /, '')
    <div class='tweet'>\nmattnhodges: Come speak with me at JAOO next week - http://jaoo.dk/<br />\n<a href='http://not.in.google/'>10:01 PM Apr 30th</a>\n</div>
    <div class='tweet'>\nSteve_Hayes: @VenessaP I think they went out for noodles. #jaoo<br />\n<a href='http://not.in.google/'>10:01 PM Apr 30th</a>\n</div>
    <div class='tweet'>\ntheRMK: Come speak with Matt at JAOO next week<br />\n<a href='http://twitter.com/theRMK/statuses/1666334207'>10:01 PM Apr 30th</a>\n</div>
    <div class='tweet'>\ndrnic: reading my own abstract for JAOO presentation<br />\n<a href='https://twitter.com/drnic/status/1666627310'>10:45 PM Apr 30th</a>\n</div>
    RESULTS
    actual = @app.render_latest_results do |tweet|
      screen_name = tweet['from_user']
      created_at = tweet['created_at']
      link = tweet['source']
      message = tweet['text']
      "<div class='tweet'>\n#{screen_name}: #{message}<br />\n<a href='#{link}'>#{created_at}</a>\n</div>\n"
    end
    assert_equal(expected, actual)
  end
  
  def test_message_render_html_formatter
    expected = <<-RESULTS.gsub(/^    /, '')
    <div class='tweet'>\nmattnhodges: Come speak with me at JAOO next week - http://jaoo.dk/<br />\n<a href='http://not.in.google/'>10:01 PM Apr 30th</a>\n</div>
    <div class='tweet'>\nSteve_Hayes: @VenessaP I think they went out for noodles. #jaoo<br />\n<a href='http://not.in.google/'>10:01 PM Apr 30th</a>\n</div>
    <div class='tweet'>\ntheRMK: Come speak with Matt at JAOO next week<br />\n<a href='http://twitter.com/theRMK/statuses/1666334207'>10:01 PM Apr 30th</a>\n</div>
    <div class='tweet'>\ndrnic: reading my own abstract for JAOO presentation<br />\n<a href='https://twitter.com/drnic/status/1666627310'>10:45 PM Apr 30th</a>\n</div>
    RESULTS
    actual = @app.render_latest_results(TweetTail::HtmlTweetFormatter)
    assert_equal(expected, actual)
  end
  
  def test_ready_for_refresh
    assert_equal('?since_id=1682666650&q=jaoo', @app.refresh_url)
  end
  
  def test_refresh_data
    @app.expects(:refresh_json_data).returns(<<-JSON)
    {
      "results": [{
        "text": "Wish I could be at #JAOO Australia...",
        "from_user": "CaioProiete",
        "id": 1711269079
      }],
      "refresh_url": "?since_id=1711269079&q=jaoo"
    }
    JSON
    @app.refresh
    expected = <<-RESULTS.gsub(/^    /, '')
    CaioProiete: Wish I could be at #JAOO Australia...
    RESULTS
    assert_equal(expected, @app.render_latest_results(nil))
    assert_equal('?since_id=1711269079&q=jaoo', @app.refresh_url)
  end
end
