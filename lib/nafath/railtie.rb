require "rails/railtie"

module Nafath
  class Railtie < Rails::Railtie
    initializer "nafath.configure" do
      # Load ENV variables into Nafath configuration automatically
      Nafath.configure do |config|
        config.app_id = ENV["NAFATH_APP_ID"]
        config.app_key = ENV["NAFATH_APP_KEY"]
        config.app_url = ENV["NAFATH_API_URL"]
      end
    end
  end
end
