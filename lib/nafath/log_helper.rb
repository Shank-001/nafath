require "logger"

module Nafath
  module LogHelper
    class << self
      def logger
        ::Logger.new(STDOUT)
      end

      def error_logger
        ::Logger.new(STDERR)
      end
    end
  end
end
