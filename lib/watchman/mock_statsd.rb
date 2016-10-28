class Watchman
  class MockStatsd

    # Used in test environments

    def gauge(metric, value); end
    def timing(metric, value); end
    def count(metric, value); end

  end
end
