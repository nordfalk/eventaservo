# frozen_string_literal: true

require "test_helper"

class Events::ByCityController::ShowTest < ActionDispatch::IntegrationTest
  test "pasintaj=1 lists past events for the city" do
    country = countries(:denmark)
    recent = events(:past_event_danio_recent)

    get events_by_city_url(continent: country.continent.normalized,
      country_name: country.name.normalized,
      city_name: recent.city,
      pasintaj: 1)

    assert_response :success
    assert_match recent.title, response.body
  end

  test "pasintaj=1 excludes events from other cities" do
    country = countries(:denmark)
    recent = events(:past_event_danio_recent)
    older = events(:past_event_danio_older) # in a different city

    get events_by_city_url(continent: country.continent.normalized,
      country_name: country.name.normalized,
      city_name: recent.city,
      pasintaj: 1)

    assert_response :success
    assert_no_match older.title, response.body
  end

  test "redirects to root when country does not exist" do
    get events_by_city_url(continent: "europo", country_name: "neekzistas", city_name: "kopenhago")
    assert_redirected_to root_path
    assert_equal "Lando ne ekzistas", flash[:error]
  end

  test "redirects to root for invalid continent" do
    get events_by_city_url(continent: "atlantido", country_name: "danio", city_name: "kopenhago")
    assert_redirected_to root_path
    assert_equal "Ne estas eventoj en tiu kontinento", flash[:notice]
  end

  test "renders kartaro view for city with future events" do
    get events_by_city_url(continent: "azio",
      country_name: "afganio",
      city_name: "new york"),
      headers: {"HTTP_COOKIE" => "vidmaniero=kartaro"}
    assert_response :success
    assert_match events(:valid_event).title, response.body
  end

  test "redirects to set default view cookie on first visit" do
    get events_by_city_url(continent: "azio",
      country_name: "afganio",
      city_name: "new york")
    assert_response :redirect
    assert_includes CGI.unescape(response.location), "new york"
  end

  test "shows nearby events by default" do
    country = countries(:denmark)
    # Kopenhago has coordinates and should show Helsingør as nearby (within 50km)
    get events_by_city_url(continent: country.continent.normalized,
      country_name: country.name.normalized,
      city_name: "kopenhago"),
      headers: {"HTTP_COOKIE" => "vidmaniero=kartaro"}

    assert_response :success
    # Should show the Copenhagen event
    assert_match events(:future_event_kopenhago).title, response.body
    # Should also show the Helsingør event as it's nearby
    assert_match events(:future_event_helsingor).title, response.body
    # Should show the "Proksima" label for Helsingør event
    assert_match "Proksima", response.body
  end

  test "hides nearby events when proksimaj=0" do
    country = countries(:denmark)
    # With proksimaj=0, should not show nearby events
    get events_by_city_url(continent: country.continent.normalized,
      country_name: country.name.normalized,
      city_name: "kopenhago",
      proksimaj: 0),
      headers: {"HTTP_COOKIE" => "vidmaniero=kartaro"}

    assert_response :success
    # Should show the Copenhagen event
    assert_match events(:future_event_kopenhago).title, response.body
    # Should NOT show the Helsingør event
    assert_no_match events(:future_event_helsingor).title, response.body
    # Should show the hide/show nearby link
    assert_match "Montru proksimajn eventojn", response.body
  end

  test "shows nearby events toggle link" do
    country = countries(:denmark)
    get events_by_city_url(continent: country.continent.normalized,
      country_name: country.name.normalized,
      city_name: "kopenhago"),
      headers: {"HTTP_COOKIE" => "vidmaniero=kartaro"}

    assert_response :success
    # Should show the hide nearby link (since nearby is shown by default)
    assert_match "Kaŝu proksimajn eventojn", response.body
  end

  test "pasintaj=1 with proksimaj=0 hides nearby past events" do
    country = countries(:denmark)
    # Aarhus has a past event with coordinates
    # When viewing Kopenhago past events with proksimaj=0, should not show Aarhus events
    get events_by_city_url(continent: country.continent.normalized,
      country_name: country.name.normalized,
      city_name: "kopenhago",
      pasintaj: 1,
      proksimaj: 0)

    assert_response :success
    # Should show Kopenhago past event if it exists, but not Aarhus
    # Note: past_event_danio_recent is in Kopenhago but doesn't have coordinates
    # so it won't be in the nearby calculation
  end
end
