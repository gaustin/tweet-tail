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
            "from_user_id": 10890961,
            "iso_language_code": "en",
            "profile_image_url": "http://example.com/",
            "created_at": "10:45 PM Apr 30th",
            "source" : "https://twitter.com/drnic/status/1666627310"
        },{
            "text": "Come speak with Matt at JAOO next week",
            "from_user": "theRMK",
            "id": 1666334207,
            "from_user_id": 10890961,
            "iso_language_code": "en",
            "profile_image_url": "http://example.com/",
            "created_at": "10:01 PM Apr 30th",
            "source": "http://twitter.com/theRMK/statuses/1666334207"
        },{
            "text": "@VenessaP I think they went out for noodles. #jaoo",
            "from_user": "Steve_Hayes",
            "id": 1666166639,
            "from_user_id": 10890961,
            "iso_language_code": "en",
            "profile_image_url": "http://example.com/",
            "created_at": "10:01 PM Apr 30th",
            "source": "http://not.in.google/"
        },{
            "text": "Come speak with me at JAOO next week - http:\/\/jaoo.dk\/",
            "from_user": "mattnhodges",
            "id": 1664823944,
            "from_user_id": 10890961,
            "iso_language_code": "en",
            "profile_image_url": "http://example.com/",
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
    assert_equal(expected, @app.render_latest_results)
  end
  
  def test_ready_for_refresh
    assert_equal('?since_id=1682666650&q=jaoo', @app.refresh_url)
  end
  
  def test_message_render_yaml
    expected = <<-RESULTS.gsub(/^    /, '')
    --- 
    - created_at: 10:01 PM Apr 30th\n  profile_image_url: http://example.com/\n  from_user: mattnhodges\n  text: Come speak with me at JAOO next week - http://jaoo.dk/\n  id: 1664823944\n  from_user_id: 10890961\n  iso_language_code: en\n  source: http://not.in.google/
    - created_at: 10:01 PM Apr 30th\n  profile_image_url: http://example.com/\n  from_user: Steve_Hayes\n  text: \"@VenessaP I think they went out for noodles. #jaoo\"\n  id: 1666166639\n  from_user_id: 10890961\n  iso_language_code: en\n  source: http://not.in.google/
    - created_at: 10:01 PM Apr 30th\n  profile_image_url: http://example.com/\n  from_user: theRMK\n  text: Come speak with Matt at JAOO next week\n  id: 1666334207\n  from_user_id: 10890961\n  iso_language_code: en\n  source: http://twitter.com/theRMK/statuses/1666334207
    - created_at: 10:45 PM Apr 30th\n  profile_image_url: http://example.com/\n  from_user: drnic\n  text: reading my own abstract for JAOO presentation\n  id: 1666627310\n  from_user_id: 10890961\n  iso_language_code: en\n  source: https://twitter.com/drnic/status/1666627310
    RESULTS
    actual = @app.latest_results.to_yaml
    assert_equal(expected, actual)
  end
  
  def test_message_render_json
    expected =
    [{"created_at"=>"10:01 PM Apr 30th",
      "profile_image_url"=>"http://example.com/",
      "from_user"=>"mattnhodges",
      "text"=>"Come speak with me at JAOO next week - http://jaoo.dk/",
      "id"=>1664823944,
      "from_user_id"=>10890961,
      "iso_language_code"=>"en",
      "source"=>"http://not.in.google/"},
     {"created_at"=>"10:01 PM Apr 30th",
      "profile_image_url"=>"http://example.com/",
      "from_user"=>"Steve_Hayes",
      "text"=>"@VenessaP I think they went out for noodles. #jaoo",
      "id"=>1666166639,
      "from_user_id"=>10890961,
      "iso_language_code"=>"en",
      "source"=>"http://not.in.google/"},
     {"created_at"=>"10:01 PM Apr 30th",
      "profile_image_url"=>"http://example.com/",
      "from_user"=>"theRMK",
      "text"=>"Come speak with Matt at JAOO next week",
      "id"=>1666334207,
      "from_user_id"=>10890961,
      "iso_language_code"=>"en",
      "source"=>"http://twitter.com/theRMK/statuses/1666334207"},
     {"created_at"=>"10:45 PM Apr 30th",
      "profile_image_url"=>"http://example.com/",
      "from_user"=>"drnic",
      "text"=>"reading my own abstract for JAOO presentation",
      "id"=>1666627310,
      "from_user_id"=>10890961,
      "iso_language_code"=>"en",
      "source"=>"https://twitter.com/drnic/status/1666627310"}]
    actual = @app.latest_results
    assert_equal(expected, actual)
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
    assert_equal(expected, @app.render_latest_results)
    assert_equal('?since_id=1711269079&q=jaoo', @app.refresh_url)
  end
end
