# Nafath

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/nafath`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'nafath'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install nafath

## Usage

# Configuration
Nafath.configure do |config|
  config.app_id = 'Your App ID'
  config.app_key = 'Your App Key'
  config.app_url = 'https://example/url/'
end

# Sending an MFA request
response = Nafath.send_request('1012345678', 'Login', 'en', SecureRandom.uuid)
puts response

# Retrieving status
status = Nafath.retrieve_status('1012345678', '3a4a3b26-3b8f-4d4f-90fe-d1a4ef834e8d', '80')
puts status

# Decoding JWT
decoded_token = Nafath.decode_jwt(jwt_token)
puts decoded_token

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/Shank-001/nafath.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
