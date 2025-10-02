# frozen_string_literal: true

require_relative "state/version"
require_relative "state/data"

# The CityState module exposes framework-agnostic helpers to list countries, states
# and cities using the underlying `city-state` gem (CS module). It provides three
# public methods: `countries`, `states(country_code)`, and `cities(country_code, state_name=nil)`.
# - countries: returns country names
# - states: expects ISO alpha-2 country code and returns state names
# - cities: returns city names; for a given state name it resolves the state code
#           and returns cities within that state; otherwise it tries country-wide
#           cities or aggregates from all states.
module CityState
  class Error < StandardError; end

  # Public API: return array of country codes or names
  def self.countries
    Data.countries&.values || []
  rescue StandardError
    []
  end

  # Public API: return array of state names for a given country code
  def self.states(country)
    return [] if blank?(country)

    Data.states(country)&.values || []
  rescue StandardError
    []
  end

  # Public API: return array of city names
  # If state is provided, fetch cities for that state within the country.
  # If state is nil/blank, attempt country-wide cities, else aggregate from all states.
  def self.cities(country, state = nil)
    return [] if blank?(country)

    state = nil if blank?(state)

    if state
      fetch_state_cities(country, state)
    else
      fetch_country_cities(country)
    end
  rescue StandardError
    []
  end

  # Rails-independent blank? check
  def self.blank?(value)
    value.respond_to?(:empty?) ? !!value.empty? : !value
  end

  # --- private helpers (module-private) ---
  def self.fetch_state_cities(country, state)
    states_hash = Data.states(country)
    state_code = states_hash&.key(state)
    return [] unless state_code

    Data.cities(state_code, country) || []
  end

  def self.fetch_country_cities(country)
    cities = Data.cities(country)
    return cities if cities&.any?

    states_hash = Data.states(country)
    return [] unless states_hash

    states_hash.keys.flat_map { |state_code| Data.cities(state_code, country) || [] }.uniq
  end
end

# Backward-compatible wrapper under the original namespace. This forwards calls to
module City
  module And
    # the `CityState` module while preserving the previous API surface used by clients.
    module State
      Error = ::CityState::Error

      def self.countries
        ::CityState.countries
      end

      def self.states(country)
        ::CityState.states(country)
      end

      def self.cities(country, state = nil)
        ::CityState.cities(country, state)
      end
    end
  end
end
