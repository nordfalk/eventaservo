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

    @show_nearby = params[:proksimaj] != "0"
    @nearby_city_names = []
    @current_city_name = params[:city_name]

    if @show_nearby && @country
      @nearby_city_names = Event.nearby_city_names(
        city_name: params[:city_name],
        country_id: @country.id
      )
    end

    city_filter = if @show_nearby && @nearby_city_names.any?
      [params[:city_name]] + @nearby_city_names
    else
      params[:city_name]
    end

    @events = build_events_scope
    @future_events = Event.by_city(city_filter).venontaj
    @today_events = @events.today.includes(:country).by_city(city_filter)
    @events = @events.not_today.by_city(city_filter)

    setup_card_pagination
  end

  private

  # Sets up assigns for the past-events view on +show+ (city).
  #
  # @return [void]
  def render_pasintaj_by_city
    @past_mode = true
    @show_nearby = params[:proksimaj] != "0"
    @nearby_city_names = []
    @current_city_name = params[:city_name]

    if @show_nearby && @country
      @nearby_city_names = Event.nearby_city_names(
        city_name: params[:city_name],
        country_id: @country.id
      )
    end

    city_filter = if @show_nearby && @nearby_city_names.any?
      [params[:city_name]] + @nearby_city_names
    else
      params[:city_name]
    end

    @events = build_events_scope
    @future_events = Event.none
    @today_events = Event.none
    @pagy, @events = pagy(
      @events.by_city(city_filter).includes(:country).order(date_start: :desc)
    )
  end
end
