# City::And::State

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/city/and/state`. To experiment with that code, run `bin/console` for an interactive prompt.

## Installation

Add to your application's Gemfile:

```ruby
gem 'city-and-state', '~> 0.1.0'
```

Then run:

```bash
bundle install
```

This gem depends on `city-state` for data.

## Usage

Public API mirrors simple needs to list countries, states, and cities.

```ruby
require "city/and/state" # defines CityState and provides City::And::State wrapper

# All countries (array of country names)
CityState.countries

# States for a country (use ISO alpha-2 code, e.g., "US", "IN")
CityState.states("US")

# Cities for a country
CityState.cities("US")

# Cities for a specific state within a country (state is the human name)
CityState.cities("US", "California")
```

Notes:
- `countries` returns names (from `CS.countries.values`).
- `states(country)` expects `country` as ISO alpha-2 code and returns state names.
- `cities(country, state=nil)` returns city names. If `state` is omitted, it tries country-level cities and otherwise aggregates from states.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/muneebrana414/city-and-state. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/muneebrana414/city-and-state/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the City::And::State project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/muneebrana414/city-and-state/blob/master/CODE_OF_CONDUCT.md).
