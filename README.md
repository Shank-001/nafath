# Nafath

The Nafath Gem provides a simple and efficient integration with the Nafath Identity Verification Service, allowing Ruby and Ruby on Rails applications to leverage Nafath's secure MFA (Multi-Factor Authentication) and identity verification features.

Features:

* Send requests for user authentication via the Nafath API.
* Retrieve the status of authentication requests.
* Handle JWT-based callback responses securely.
* Easily configurable with your Nafath credentials.

This gem simplifies the process of integrating Nafath services into your application, ensuring secure and reliable identity verification with minimal setup.
<!-- Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/nafath`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem -->

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

URL for Pre-Prod (Testing): ``` 'https://nafath.api.elm.sa/stg/' ```

URL for Prod:               ``` 'https://nafath.api.elm.sa/' ```


### Configuration:

First make an initializer nafath.rb inside config/initializers and add the configurations (Currently Unsupported)

```ruby
Nafath.configure do |config|
  config.app_id  = 'Your App ID'
  config.app_key = 'Your App Key'
  config.app_url = 'https://nafath.api.elm.sa/stg/'
end
```
Or else add set these variables in `.env` file. (Please prefer this for now. 🙂)

```ruby
NAFATH_APP_ID  = 'Your App ID'
NAFATH_APP_KEY = 'Your App Key'
NAFATH_API_URL = 'https://nafath.api.elm.sa/stg/'
```


```ruby
# Sending an MFA request
response = Nafath.send_request('10xxxxxx78', 'Login', 'en', SecureRandom.uuid)
# Refer Official Doc for Service types, e.g. 'Login', 'DigitalServiceEnrollmentWithoutBio'  
puts response

# Retrieving status
status = Nafath.retrieve_status('10xxxxxx78', '3a4axxxx-xxxx-xxxx-xxxx-xxxxef834e8d', '80')
puts status

# Decoding JWT
decoded_token = Nafath.decode_jwt(jwt_token)
puts decoded_token
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/Shank-001/nafath.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
