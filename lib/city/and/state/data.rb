# frozen_string_literal: true

require 'yaml'

module CityState
  module Data
    FILES_FOLDER = File.expand_path('../../db', __FILE__)
    MAXMIND_DB_FN = File.join(FILES_FOLDER, 'GeoLite2-City-Locations-en.csv')
    COUNTRIES_FN = File.join(FILES_FOLDER, 'countries.yml')

    ID = 0
    COUNTRY = 4
    COUNTRY_LONG = 5
    STATE = 6
    STATE_LONG = 7
    CITY = 10

    @countries = {}
    @states = {}
    @cities = {}
    @current_country = nil
    @maxmind_zip_url = nil
    @license_key = nil

    class << self
      def countries
        if File.exist?(COUNTRIES_FN)
          @countries = symbolize_keys(YAML.load_file(COUNTRIES_FN))
        elsif File.exist?(MAXMIND_DB_FN)
          build_countries_from_csv
        else
          @countries = {}
        end
        @countries
      end

      # Allow configuring the MaxMind download URL or license key like city-state
      def set_maxmind_zip_url(maxmind_zip_url)
        @maxmind_zip_url = maxmind_zip_url
      end

      def set_license_key(license_key)
        url = "https://download.maxmind.com/app/geoip_download?edition_id=GeoLite2-City-CSV&license_key=#{license_key}&suffix=zip"
        @license_key = license_key
        set_maxmind_zip_url(url)
      end

      # Download and extract the GeoLite2 CSV locally
      def update_maxmind
        require 'open-uri'
        require 'zip'

        return false unless @maxmind_zip_url
        f_zipped = URI.open(@maxmind_zip_url)

        Zip::File.open(f_zipped) do |zip_file|
          zip_file.each do |entry|
            if present?(entry.name['GeoLite2-City-Locations-en'])
              fn = entry.name.split('/').last
              entry.extract(File.join(FILES_FOLDER, fn)) { true }
              break
            end
          end
        end
        true
      end

      # Update all cached/generated files, mirroring city-state's behavior
      def update
        update_maxmind
        Dir[File.join(FILES_FOLDER, 'states.*')].each do |state_fn|
          install(state_fn.split('.').last.upcase.to_sym)
        end
        @countries = {}
        @states = {}
        @cities = {}
        File.delete(COUNTRIES_FN) if File.exist?(COUNTRIES_FN)
        true
      end

      def states(country)
        return {} if country.nil?

        self.current_country = country
        country = current_country

        if blank?(@states[country])
          states_fn = File.join(FILES_FOLDER, "states.#{country.to_s.downcase}")
          if !File.exist?(states_fn)
            install(country) if File.exist?(MAXMIND_DB_FN)
          end
          @states[country] = File.exist?(states_fn) ? symbolize_keys(YAML.load_file(states_fn)) : {}
        end

        @states[country] || {}
      end

      def cities(state, country = nil)
        self.current_country = country if present?(country)
        country = current_country
        state = state.to_s.upcase.to_sym

        if blank?(@cities[country])
          cities_fn = File.join(FILES_FOLDER, "cities.#{country.to_s.downcase}")
          if !File.exist?(cities_fn)
            install(country) if File.exist?(MAXMIND_DB_FN)
          end
          @cities[country] = File.exist?(cities_fn) ? symbolize_keys(YAML.load_file(cities_fn)) : {}
          # deduplicate
          @cities[country].each { |key, arr| @cities[country][key] = (arr || []).uniq }
        end

        (@cities[country] || {})[state]
      end

      def get(country = nil, state = nil)
        return countries if country.nil?
        return states(country) if state.nil?
        cities(state, country)
      end

      def current_country
        return @current_country if present?(@current_country)

        fn = Dir[File.join(FILES_FOLDER, 'cities.*')].last
        @current_country = blank?(fn) ? nil : fn.split('.').last
        if blank?(@current_country)
          @current_country = :US
          install(@current_country) if File.exist?(MAXMIND_DB_FN)
        else
          @current_country = @current_country.to_s.upcase.to_sym
        end
        @current_country
      end

      def current_country=(country)
        @current_country = country.to_s.upcase.to_sym
      end

      # Build states.* and cities.* for one country using local CSV
      def install(country)
        return false unless File.exist?(MAXMIND_DB_FN)

        country = country.to_s.upcase

        states_replace_fn = File.join(FILES_FOLDER, 'states-replace.yml')
        states_replace = File.exist?(states_replace_fn) ? symbolize_keys(YAML.load_file(states_replace_fn)) : {}
        states_replace = states_replace[country.to_sym] || {}
        states_replace_inv = states_replace.invert

        cities = {}
        states = {}

        File.foreach(MAXMIND_DB_FN) do |line|
          rec = line.split(',')
          next if rec[COUNTRY] != country
          next if (blank?(rec[STATE]) && blank?(rec[STATE_LONG])) || blank?(rec[CITY])

          rec[STATE] = states_replace_inv[rec[STATE_LONG]] if blank?(rec[STATE])
          rec[STATE] = rec[STATE_LONG] if blank?(rec[STATE])
          rec[STATE_LONG] = states_replace[rec[STATE]] if blank?(rec[STATE_LONG])

          rec[STATE] = rec[STATE].to_sym
          rec[CITY].gsub!(/\"/, '')
          rec[STATE_LONG].gsub!(/\"/, '')

          cities.merge!({ rec[STATE] => [] }) unless states.key?(rec[STATE])
          cities[rec[STATE]] << rec[CITY]

          unless states.key?(rec[STATE])
            states.merge!({ rec[STATE] => rec[STATE_LONG] })
          end
        end

        cities = Hash[cities.sort]
        states = Hash[states.sort]
        cities.each { |k, v| cities[k] = (v || []).sort }

        states_fn = File.join(FILES_FOLDER, "states.#{country.downcase}")
        cities_fn = File.join(FILES_FOLDER, "cities.#{country.downcase}")
        File.open(states_fn, 'w') { |f| f.write states.to_yaml }
        File.open(cities_fn, 'w') { |f| f.write cities.to_yaml }
        true
      end

      # Helpers
      def blank?(obj)
        obj.respond_to?(:empty?) ? !!obj.empty? : !obj
      end

      def present?(obj)
        !blank?(obj)
      end

      def symbolize_keys(obj)
        obj.transform_keys { |key| key.to_sym rescue key }
      end

      private

      def build_countries_from_csv
        @countries = {}
        File.foreach(MAXMIND_DB_FN) do |line|
          rec = line.split(',')
          next if blank?(rec[COUNTRY]) || blank?(rec[COUNTRY_LONG])
          code = rec[COUNTRY].to_s.upcase.to_sym
          next if present?(@countries[code])
          long = rec[COUNTRY_LONG].gsub(/\"/, '')
          @countries[code] = long
        end
        @countries = Hash[@countries.sort]
        File.open(COUNTRIES_FN, 'w') { |f| f.write @countries.to_yaml }
        @countries
      end
    end
  end
end


