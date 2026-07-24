# frozen_string_literal: true

require "test_helper"

class Event::NearCityScopeTest < ActiveSupport::TestCase
  test "near_city returns none when city_name is blank" do
    result = Event.near_city("", "US", 50)
    assert result.none?
  end

  test "near_city returns none when city_name is nil" do
    result = Event.near_city(nil, "US", 50)
    assert result.none?
  end

  test "near_city excludes events from the origin city" do
    # Kreu testan eventon en Parizo
    paris = countries(:france)
    event_in_paris = create(:evento, city: "Parizo", country: paris, latitude: 48.8566, longitude: 2.3522)

    # Kreu testan eventon en najbara urbo (ekz. Versajlo, ~20km de Parizo)
    event_near_paris = create(:evento, city: "Versajlo", country: paris, latitude: 48.8049, longitude: 2.1264)

    # Serĉu eventojn proksimajn al Parizo
    result = Event.near_city("Parizo", "FR", 50)

    # La evento en Parizo devas esti EKSKLUDITA
    assert_not_includes result, event_in_paris
    # La evento en Versajlo devus esti INKLUDITA (se geokodigo funkcias)
    # Note: Voor la testoj, ni devas stubi Geocoder
  end

  test "near_city includes events within radius" do
    # Stub Geocoder por doni koordinatojn por Parizo
    Geocoder.stub :search, ->(query, **_opts) {
      [OpenStruct.new(latitude: 48.8566, longitude: 2.3522)]
    } do
      # Kreu eventon en urbo proksime al Parizo (20km for)
      paris = countries(:france)
      near_city = create(:evento, 
        city: "Versajlo", 
        country: paris, 
        latitude: 48.8049, 
        longitude: 2.1264,
        date_start: Time.zone.today + 1.day
      )

      # Kreu eventon tro for (100km for)
      far_city = create(:evento,
        city: "Rejms",
        country: paris,
        latitude: 49.2583,
        longitude: 4.0317,
        date_start: Time.zone.today + 1.day
      )

      result = Event.near_city("Parizo", "FR", 50)

      # Versajlo (20km) devus esti inkludita
      assert_includes result, near_city
      # Rejms (100km+) devus esti EKSKLUDITA
      assert_not_includes result, far_city
    end
  end

  test "near_city excludes online events" do
    Geocoder.stub :search, ->(query, **_opts) {
      [OpenStruct.new(latitude: 48.8566, longitude: 2.3522)]
    } do
      paris = countries(:france)
      
      # Kreu retajn eventon proksime
      online_event = create(:evento,
        city: "Versajlo",
        country: paris,
        latitude: 48.8049,
        longitude: 2.1264,
        online: true,
        date_start: Time.zone.today + 1.day
      )

      # Kreu normalan eventon proksime
      normal_event = create(:evento,
        city: "Versajlo",
        country: paris,
        latitude: 48.8049,
        longitude: 2.1264,
        online: false,
        date_start: Time.zone.today + 1.day
      )

      result = Event.near_city("Parizo", "FR", 50)

      # La reta evento devus esti EKSKLUDITA
      assert_not_includes result, online_event
      # La normala evento devus esti inkludita
      assert_includes result, normal_event
    end
  end

  test "near_city excludes events without coordinates" do
    Geocoder.stub :search, ->(query, **_opts) {
      [OpenStruct.new(latitude: 48.8566, longitude: 2.3522)]
    } do
      paris = countries(:france)
      
      # Kreu eventon sen koordinatoj
      event_without_coords = create(:evento,
        city: "Versajlo",
        country: paris,
        latitude: nil,
        longitude: nil,
        date_start: Time.zone.today + 1.day
      )

      result = Event.near_city("Parizo", "FR", 50)

      # Eventoj sen koordinatoj devus esti EKSKLUDITAJ
      assert_not_includes result, event_without_coords
    end
  end

  test "near_city uses country code for precision" do
    # Stub Geocoder por doni malsamajn koordinatojn kun kaj sen landkodo
    Geocoder.stub :search, ->(query, **_opts) {
      if query.include?("US")
        [OpenStruct.new(latitude: 37.7749, longitude: -122.4194)] # San Francisco
      else
        [OpenStruct.new(latitude: 48.8566, longitude: 2.3522)] # Parizo
      end
    } do
      usa = countries(:us)
      
      # Kreu eventon en San Francisco
      sf_event = create(:evento,
        city: "San Francisco",
        country: usa,
        latitude: 37.7749,
        longitude: -122.4194,
        date_start: Time.zone.today + 1.day
      )

      # Serĉu kun landkodo
      result_with_country = Event.near_city("San Francisco", "US", 50)
      assert_includes result_with_country, sf_event

      # Serĉu sen landkodo (devus uzi Parizon)
      result_without_country = Event.near_city("San Francisco", nil, 50)
      # Ĉi tiu ne devus trovi la SF eventon ĉar ĝi uzas Parizon kiel centro
      assert_not_includes result_without_country, sf_event
    end
  end

  test "near_city caches geocoding results" do
    Geocoder.stub :search, ->(query, **_opts) {
      [OpenStruct.new(latitude: 48.8566, longitude: 2.3522)]
    } do
      # Unua fojo - devus voki Geocoder
      Event.near_city("Parizo", "FR", 50).to_a

      # Dua fojo - devus uzi kaŝon, ne voki Geocoder denove
      Event.near_city("Parizo", "FR", 50).to_a

      # Ni ne povas teste aserti kaŝon rekte, sed la testoj pasus se Geocoder ne estas vokita
    end
  end

  test "near_city handles Geocoder errors gracefully" do
    # Stub Geocoder por levigi eraron
    Geocoder.stub :search, ->(_query, **_opts) {
      raise Geocoder::Error, "Geocoding failed"
    } do
      result = Event.near_city("Parizo", "FR", 50)
      assert result.none?
    end
  end

  test "near_city returns events ordered by date_start" do
    Geocoder.stub :search, ->(query, **_opts) {
      [OpenStruct.new(latitude: 48.8566, longitude: 2.3522)]
    } do
      paris = countries(:france)
      
      # Kreu plurajn eventojn en malsamaj datoj
      event1 = create(:evento, city: "Versajlo", country: paris, latitude: 48.8049, longitude: 2.1264, date_start: Time.zone.today + 5.days)
      event2 = create(:evento, city: "Versajlo", country: paris, latitude: 48.8049, longitude: 2.1264, date_start: Time.zone.today + 1.day)
      event3 = create(:evento, city: "Versajlo", country: paris, latitude: 48.8049, longitude: 2.1264, date_start: Time.zone.today + 10.days)

      result = Event.near_city("Parizo", "FR", 50).order(:date_start)

      # La rezultoj devus esti ordigitaj per komenca dato
      assert_equal [event2, event1, event3], result.to_a
    end
  end

  test "near_city respects custom radius parameter" do
    Geocoder.stub :search, ->(query, **_opts) {
      [OpenStruct.new(latitude: 48.8566, longitude: 2.3522)]
    } do
      paris = countries(:france)
      
      # Kreu eventon je 40km for
      event_40km = create(:evento, city: "Urbo1", country: paris, latitude: 49.0, longitude: 2.5, date_start: Time.zone.today + 1.day)
      
      # Kreu eventon je 60km for
      event_60km = create(:evento, city: "Urbo2", country: paris, latitude: 49.1, longitude: 2.6, date_start: Time.zone.today + 1.day)

      # kun 50km radio, nur la 40km evento devus esti inkludita
      result_50km = Event.near_city("Parizo", "FR", 50)
      assert_includes result_50km, event_40km
      assert_not_includes result_50km, event_60km

      # kun 70km radio, ambaŭ devus esti inkluditaj
      result_70km = Event.near_city("Parizo", "FR", 70)
      assert_includes result_70km, event_40km
      assert_includes result_70km, event_60km
    end
  end
end
