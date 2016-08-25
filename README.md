# Mitake

Taiwan SMS Provider Mitake API

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'mitake'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install mitake

## Usage

Initialize mitake api:
    
    mitake = Mitake::API.new(username: YOUR_USERNAME, password: YOUR_PASSWORD)

Get Account Balance:
    
    mitake.get_balance

Send Message:

    mitake.send_sms(numbers: DEST_MOBILE, message: YOUR_MESSAGE)
    mitake.send_sms(numbers: [DEST_MOBILE1, DEST_MOBILE2, DEST_MOBILE3], message: YOUR_MESSAGE)

Get Message Status:

    mitake.get_message(msgid: MESSAGE_ID)
    mitake.get_message(msgid: MESSAGE_ID1, MESSAGE_ID2, MESSAGE_ID3)

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/j094097/mitake. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

