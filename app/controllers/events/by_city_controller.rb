# frozen_string_literal: true

# Controller for browsing events by city.
#
# Handles the +/:continent/:country_name/:city_name+ route, listing events
# filtered by city. Supports card and map view modes.
class Events::ByCityController < ApplicationController
  include EventBrowsing

  helper EventsHelper

  before_action :validate_continent
  before_action :set_country

  def show
    redirect_to root_url, flash: {error: "Lando ne ekzistas"} and return if @country.nil?

    if params[:pasintaj].present?
      render_pasintaj_by_city
      return
    end

    unless cookies[:vidmaniero].in? %w[kartaro mapo]
      cookies[:vidmaniero] = {value: "kartaro", expires: 2.weeks, secure: true}
      redirect_to events_by_city_url(continent: params[:continent].normalized, country_name: params[:country_name].downcase, city_name: params[:city_name].downcase) and return
    end

    @events = build_events_scope
    @future_events = Event.by_city(params[:city_name]).venontaj
    @today_events = @events.today.includes(:country).by_city(params[:city_name])
    @events = @events.not_today.by_city(params[:city_name])

    # Aldonu proksimajn eventojn de najbaraj urboj (50km radio)
    @nearby_events = load_nearby_events

    setup_card_pagination
  end

  private

  # Ŝargas proksimajn eventojn de najbaraj urboj (50km radio)
  #
  # @return [ActiveRecord::Relation] eventoj el najbaraj urboj
  def load_nearby_events
    return Event.none if @country.blank?

    Event.near_city(params[:city_name], @country.code, 50)
      .venontaj
      .includes(:country)
      .order(date_start: :asc)
      .limit(20)
  rescue Geocoder::Error => e
    Rails.logger.warn "Geocoder error loading nearby events for #{params[:city_name]}: #{e.message}"
    Event.none
  end

  # Sets up assigns for the past-events view on +show+ (city).
  #
  # @return [void]
  def render_pasintaj_by_city
    @past_mode = true
    @events = build_events_scope
    @future_events = Event.none
    @today_events = Event.none
    @pagy, @events = pagy(
      @events.by_city(params[:city_name]).includes(:country).order(date_start: :desc)
    )
  end
end
