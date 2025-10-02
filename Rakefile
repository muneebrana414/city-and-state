# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

require "rubocop/rake_task"

RuboCop::RakeTask.new

task default: %i[spec rubocop]

namespace :data do
  desc "Download/update GeoLite2 CSV and rebuild local countries/states/cities"
  task :update do
    require_relative "lib/city/and/state/data"

    # Allow passing LICENSE_KEY env to configure download
    license = ENV["LICENSE_KEY"] || ENV["MAXMIND_LICENSE_KEY"]
    CityState::Data.set_license_key(license) if license

    CityState::Data.update
    puts "Data updated in lib/db"
  end
end
