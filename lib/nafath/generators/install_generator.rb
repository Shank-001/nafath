require "rails/generators"

module Nafath
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("templates", __dir__)

      def create_initializer_file
        template "nafath_initializer.rb", "config/initializers/nafath.rb"
      end
    end
  end
end
