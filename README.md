# Safecrow

This is SDK for Safecrow API

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'safecrow'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install safecrow

## Usage

First, configure api-key and api-secret in config/initializers/safecrow.rb

```ruby
Safecrow.method_name(params).
```
 To all availible methods see lib/safecrow.rb and https://github.com/safecrow/docs-apiv3
 

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `URL='url' APIKEY='apikey' APISECRET='apisecret' PREFIX='/api/v3' rspec` to run the tests.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/safecrow. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).