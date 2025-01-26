module Nafath
  class Configuration
    attr_accessor :app_id, :app_key, :app_url

    def initialize
      @app_id = nil
      @app_key = nil
      @app_url = nil
    end
  end
end